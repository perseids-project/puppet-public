# Puppet roles and profiles

## What I'm going to tell you

This document explains what roles and profiles are in Puppet manifests, why we use them, and how they relate to things like nodes and classes.

## Not actually a thing

We hear a lot about Puppet 'roles' and 'profiles' these days. As a matter of fact, these aren't features of Puppet. Puppet the tool is entirely agnostic about how you organize your Puppet code. It's perfectly fine to put everything in one big file, or even just a string on the command line:
    
    # puppet apply -e "package { 'ntp': ensure => installed }"
    Notice: Compiled catalog for monitor.perseids.org in environment production in 0.40 seconds
    Notice: /Stage[main]/Main/Package[atop]/ensure: created
    Notice: Applied catalog in 2.09 seconds
  
## Classes

However, with non-trivial Puppet manifests, even though the computer has no difficulty understanding a huge indigestible blob of code, it's not so easy for us humans.

In the bad old days, Puppet code often looked like this:

    node 'server1' {
      package { 'ntp':
        ensure => installed,
      }
      ...
    }
  
All the code and resources for configuring a server were right there in its node definition. Crude, but it works. Maintenance, however, rapidly becomes a headache. We need to organize this code better.

The first step we usually take towards organizing code is to arrange it into classes:

    # Run an NTP daemon
    class ntp {
      package { 'ntp':
        ensure => installed,
      }

      service { 'ntp':
        ensure  => running,
        require => Package['ntp'],
      }
    }
    
Instead of having to repeat this code in the manifests of all servers which need NTP, we can just `include` it:

    node 'server1' {
      include ntp
    }
    
## Modules

We could actually get by just fine with only classes (or even without them). But it's often convenient to use a higher-level organizing unit: the module. A Puppet module is basically a namespace. You can name your classes anything you like within a module, without worrying that it'll interfere with some other class of the same name elsewhere.

The module is usually the basic unit of code reuse and exchange. Puppet code to manage particular software and services (Docker or Icinga, for example) is commonly distributed as a module. 

## Introducing roles

One of the powerful principles of object-oriented programming is that it's somewhat self-documenting. The names we give objects reflect what they do, and this means that reading the code gives you some idea of what it's trying to achieve.

The problem with just stuffing classes (or even modules) into nodes is that it doesn't tell the reader much about why they're there:

    node 'server1' {
      include ntp
      include apache
      include tomcat
      include ssh
      include sudoers
      include myapp
      ...
    }

It's not clear from this what `server1` is actually for. We know what _classes_ it has, but why?

It would be much clearer if we made a new class whose only purpose is to have a descriptive name, and to contain other classes:

    node 'server1' {
      include app_server
    }

    class app_server {
      include ntp
      include apache
      include tomcat
      include ssh
      include sudoers
      include myapp
      ...
    }

It's now quite plain that `server1` is an `app_server`. When we create a class like this whose purpose is to document what a node _does_, we call it a _role_. Remember, this isn't a term that has meaning to Puppet. A class is a special kind of object in Puppet, and so is a module, but a role is just a class that we're using in a particular way: to describe what a node does. One node, one role. (This isn't always the case, as servers can have more than one role: they could be a Git server as well as a monitoring server, for example, or they could be an app server for several different apps, or several servers could all have the same role, but let's stick to the 'one node, one role' idea for the time being.)

## The `role` module

Just as we organize ordinary classes into modules for neatness, let's do the same with our role classes. You can call this module anything you like, but `role` seems a straightforward choice:

    node 'server1' {
      include role::app_server
    }

    class role::app_server {
      include ntp
     ...
    }

## What about profiles?

If roles are classes whose name defines the server's purpose (such as `app_server`), what are profiles? Well, let's look again at the list of classes included in the `app_server` role:

    include ntp
    include apache
    include tomcat
    include ssh
    include sudoers
    include myapp
    ...

The first example there is `ntp`, which means we want NTP time synchronisation for the server. The code given will include the `ntp` module. So where does that module come from?

Well, you could perfectly well write your own `ntp` module, but it makes much more sense to use an existing one (from Puppet Forge, for example). Such a module will be necessarily generic. We probably want to customise it a little for our own particular site setup.

For example, we might want to supply the address of a local NTP server, rather than using the defaults. Code like this would work:

    class { 'ntp':
      servers => [ 'ntp.internal.example.com' ],
    }
    
This is now customised for our own site. We could include this code in each server role that requires NTP (probably all of them):

    class role::app_server {
      class { 'ntp':
        servers => [ 'ntp.internal.example.com' ],
      }
    }
    
    class role::db_server {
      class { 'ntp':
        servers => [ 'ntp.internal.example.com' ],
      }
    }

    class role::load_balancer {
      class { 'ntp':
        servers => [ 'ntp.internal.example.com' ],
      }
    }
    
As you can see, this gets repetitive quickly, and we end up with lots of duplicated code which is going to be hard to maintain. Also, the role classes are cluttered with irrelevant site-specific detail. A 10x Puppet engineer would refactor this duplicated code into a special _site-specific_ `ntp` class:

    class profile::ntp {
      class { 'ntp':
        servers => [ 'ntp.internal.example.com' ],
      }
    }
    
    class role::app_server {
      include profile::ntp
    }
    
    class role::db_server {
      include profile::ntp
    }

    class role::load_balancer {
      include profile::ntp
    }
  
So much nicer! We need a name for this kind of class, which encapsulates site-specific information about how to configure a generic module. I guess the code example gave away the punchline. It's called a _profile_.

A profile is a class which says "This is how we use NTP at our site". Instead of modifying a third-party module to make it specific to our requirements, we use the module in a completely generic way, wrapping it inside a profile. Roles which require it can then include that profile, rather than lots of duplicated site-specific code:

    class role::app_server {
      include profile::ntp
      include profile::apache
      include profile::tomcat
      include profile::ssh
      include profile::sudoers
      include profile::myapp
    }

## What I just told you

So now we know that a _node_ describes a particular server, a _role_ documents what the server is for, a _profile_ wraps a generic module with site-specific configuration, and a _module_ encapsulates a bunch of related Puppet resources which do something useful, here is the overall hierarchy that shows how they interact:

  * A *node* has (usually one, but possibly) many *roles*
  * A *role* has many *profiles*
  * A *profile* has (potentially) many *modules*
  * A *modules* has many *resources* (which may or may not be further organised into *classes*)

## Further reading

  * [Designing Puppet - Roles and Profiles](http://www.craigdunn.org/2012/05/239/)
  * [Building a Functional Puppet Workflow Part 2: Roles and Profiles](http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/)
  * [Intro to Roles and Profiles with Puppet and Hiera](https://rnelson0.com/2014/07/14/intro-to-roles-and-profiles-with-puppet-and-hiera/)

