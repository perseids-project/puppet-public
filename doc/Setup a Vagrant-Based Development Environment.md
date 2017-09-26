# Setup a Vagrant-Based Perseids Development Environment

The Vagrant based Perseids Development Environment creates an instance of an Ubuntu 14.04 server 
provisioned with the folloiwng core services of the Perseids platform:

* SoSOL (with eXist)
* Perseids-Client-Apps
* Arethusa
* Annotation Editor
* Alpheios Alignment Editor
* LLT Tokenizer

All other services are referenced from the production environment.

## Prerequisites

* Vagrant installed and working
* The GPG secret key for the Perseids puppet repo imported into your local GPG keystore
   * The local vagrant instance needs to have the key which was used to encrypt passwords and other secrets in the `data/secret.eyaml` hiera file. `scripts/copy_key_to_vagrant.sh` is triggered by the Vagrant file provisioning before `scripts/vagrant_provision.sh`. You need to get a copy of the GPG secret key from the Perseids system administrator and import it via `gpg -- import` before proceeding.
* Ports 8080, 3000 and 8800 free on your host machine
    * The configuration templates assume these ports. It's possible to 
      use others but the puppet-installed configuration files will need
      to be updated to point at your alternate ports.

## Create a puppetized Vagrant instance

1. Clone the perseids-puppet repository

    ```
    git clone https://github.com/perseids-project/perseids-puppet 
    ```

2. Run the start_vagrant script from the root of the cloned repo

   ```
   cd perseids-puppet
   scripts/start_vagrant.sh
   ```

3. Start a shell session on the vagrant box, reapply puppet and then lock puppet so that you can develop without your files being overwritten.
   

   ```
   vagrant ssh
   sudo - su 
   papply  
   plock development
   ```


4. Run the SoSOL development server on port 3000

    ```
    sudo su - deployer
    cd /home/deployer/sosol
    bundle exec rails server
    ```


5. Run the LLT tokenizer on port 8088 (only needed if you want to develop
   or test CTS Passage Annotations

    ```
    sudo su - deployer
    cd /home/deployer/llt
    bundle exec rackup --port 8088 
    ```
 
6. Access SoSOL on your host machine
    ```  
    http://localhost:3000
    ```
## Development Environment Details

All application code gets installed under ownership of the `deployer` user id.

### SoSOL

SoSOL is installed in `/home/deployer/sosol`. 

The version of jruby used is specified in the `sosol::jruby_version` hiera setting in `data/common.yaml`

Puppet runs `/usr/local/bin/install_sosol_local.sh` (built from a puppet template in `site_modules/sosol/templates` to install the dependencies into the deployer rvm environment.

Tool URLs (Arethusa, Alpheios, Annotation Editor, Tokenizer) are defined in the tools.yml config file. The template for this is in the puppet repo in `site_modules/sosol/templates/tools.yml.epp`. 

If you need to change mapped ports for your Vagrant box, you will need to at a minimum update the urls for the :development rails environment here, but you will also need to update configuration files for each of the individual tools.

To build and run updates to local SoSOL code:

    sudo su - deployer
    cd /home/deployer/sosol
    bundle exec rails server

### Perseids Client Apps

Perseids Client Apps code is installed in `/usr/local/perseids-client-apps` and deployed as an Apache mod_wsgi module under the webserver running on port 8080 (configured in puppet manifest `site_modules/sosol/manifests/web.pp`).

If you change the mapped ports for your Vagrant setup, you may need to update the urls in the configuration files. The configuration file puppet templates are kept in `site-modules/site/templates/profiles`.

If you make local changes to the perseids-client-apps code, you will need to bounce the local apache service in order to deploy them.

### Arethusa

Arethusa code is installed in `/home/deployer/arethusa` and deployed to Apache in `/var/www/tools/arethusa`.  The SoSOL tools development configuration points at the perseids_local configuration file for Arethusa.  

If you change the mapped ports for your Vagrant setup, you will need to update the urls in the `perseids_local.json` file for Arethusa, as well as in the files included by this configuration file.

To build local changes to Arethusa code run:

```
sudo su - deployer
cd /home/deployer/arethusa
bash --login /usr/local/bin/build-arethusa
```

To deploy local changes to Arethusa code run:

```
sudo su - root
cd /home/deployer/arethusa
/usr/local/bin/deploy-arethusa /var/www/tools
```

### Annotation Editor

The annotation editor code is installed directly in the Apache document root at  `/var/www/tools/annotation-editor`.  Local changes will be deployed automatically.

The SoSOL tools development configuration points at the `perseids-annotate-dev.xhtml` driver file for this application. If you change the mapped ports for your Vagrant box you may need to update the URLs referenced in this file.

### Alpheios Alignment Editor

The Alpheios Alignment Editor is installed from its GitHub tarball as part of the Dockerized eXist repository that accompanies SoSOL.  This is managed by the puppet manifest at `site_modules/sosol/manifests/exist.pp`.  If you want to test local changes to the Alpheios Alignment Editor, the simplest approach is to use the eXist client to upload the modified files from your local machine to the Dockerized eXist instance.  (This breaks the Docker philosophy, but getting Vagrant and Docker to download and use new tarballs from GitHub via Puppet is problematic. You need to clear the cache and it requires commits to GitHub before testing.)  The eXist instance is exposed at http://localhost:8800 and you can login via the eXist client as `admin/admin`.

The SoSOL tools development configuration points at the `align-editsentence-perseids-test.xhtml` driver file for this application. If you change the mapped ports for your Vagrant box you may need to update the URLs referenced in this file.

### LLT Tokenizer

The LLT Tokenizer is installed in `/home/deployer/llt` and `/home/deployer/llt-db_handler` (other llt gems are pulled directly from GitHub).  It is setup to use the same version of JRuby as SoSOL. In the Vagrant development environment the LLT Tokenizer service is not run automatically or deployed to Tomcat as it is in production.  The `/usr/bin/install_llt_local.sh` script (puppet template for which is in `site_modules/site/profiles/llt/install_llt_local.sh.epp`) installs the dependencies.  To test local changes to the code or to just make the service available for use with the Perseids-Client-App and Annotation Editor, run:

    ```
    sudo su - deployer
    cd /home/deployer/llt
    bundle exec rackup --port 8088 
    ```

## Troubleshooting/Customizations

### Docker DNS

If the eXist Docker image cannot be built, you may need to change the dns
used by docker to your local DNS server. The default setting is Google
DNS `8.8.8.8` but for Vagrant sometimes a local server is required. In
the `data/common.yaml' change the `docker::dns` setting to your local address
e.g. 192.168.1.1.

### Changing Source Branches

The puppet hiera configuration file, `data/common.yaml` specifies the release
tags for each code base that gets installed.  If you are going to be developing
code for these applications you may want to switch to master or your own branch.The following settings are relevant for the applications installed in the 
development environment:

  * SoSOL: `sosol::release_version`
  * Annotation Editor: `sosol::annotation_editor::release_version`
  * Arethusa: `arethusa::app_version`
  * Perseids Client Apps: `pca::app_release`
  * Alignment Editor: `sosol::alignment_editor_url`

### CORS Access

In order to get CORS access working in the Development environment, the external tools communicate with SoSOL via an Apache proxy.  The subset of the local SoSOL paths needed for interaction with these tools have been explicitly proxied.  These paths are set in puppet hiera config file `data/common.yaml` settings. Proxies are also configured for the eXist database and the llt tokenizer. If you change mapped ports for your Vagrant setup you may need to change these settings:

```
sosoldev::proxy_paths:
    - path: '/dmm_api'
      url: 'http://localhost:3000/dmm_api'
    - path: '/api'
      url: 'http://localhost:3000/api'
    - path: '/cts'
      url: 'http://localhost:3000/cts'
    - path: '/alpheios/repository'
      url: '!'
    - path: '/alpheios'
      url: 'http://localhost:8800/exist/rest/db'
    - path: '/llt'
      url: 'http://localhost:8088'
```


