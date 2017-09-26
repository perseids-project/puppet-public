# Overview
Perseids' services are grouped on nodes. The nodes are outlined in the [site.pp](https://github.com/perseids-project/perseids-puppet/blob/master/manifests/site.pp) manifest.

The services available on any given node are described in the [roles](https://github.com/perseids-project/perseids-puppet/tree/master/site-modules/site/manifests/roles) manifest
for the node. 

These role manifests include both common profiles reused across multiple nodes, and service specific profiles for the services 
deployed on the node.  

The quickest way to see what service(s) a given node hosts is to look at the role manifest that corresponds to that node name.

# Node Short Descriptions

## sosol (sosol.perseids.org)

The [sosol node](https://github.com/perseids-project/perseids-puppet/blob/master/site-modules/site/manifests/roles/sosol.pp) hosts the core of the Perseids platform, the Son of Suda Online (SoSOL) Ruby on Rails webapp.  Its data source is a local git repository and a mySQL database (hosted on AWS RDBMS)
The JRuby on Rails SoSOL app is deployed as a war flie under tomcat and proxied by Apache.

It also hosts an auxiliary eXist database (via Docker) and an annotation tool under Apache.

SoSOL is a Service Provider for the Tufts Shibboleth IdP.


## services (services.perseids.org, and various others)

The [services node](https://github.com/perseids-project/perseids-puppet/blob/master/site-modules/site/manifests/roles/services.pp) hosts a wide variety of different services supporting Perseids. Most are proxied via Apache under services.perseids.org.

__CapiTainS Nemo/Nautilus (cts.perseids.org)__ : python flask app serving Perseus Texts and Plokamos annotation tool.

__Fuseki (fuseki.perseids.org)__ : Fuseki Triple Store.  Primarily for supporting legacy Cite Collection data and manuscript images.

__llt (services.perseids.org/llt)__: jruby webapp deployed under tomcat providing segmentation, tokenization and review services for Perseids annotation environments. (datasource: local postgres)

__sg (services.perseids.org/sg)__: jruby webapp deployed under tomcat providing Smyth Grammar features to the Perseids/Arethusa treebanking environment

__cite_mapper (services.perseids.org/cite_mapper)__: jruby webapp deployed under tomcat providing mapping between abbreviations and CTS urns for Perseids annotation environments.

__citefusioncoll (services.perseids.org/collections)__: groovy webapp deployed under tomcat providing access to lexical inventory data (datasource: google fusion tables)

__fghproxy (fgh.perseids.org)__: Flask GitHub proxy. Proxies access to GitHub repositories from Perseids.

## annotation (annotation.perseids.org)

The [annotation node](https://github.com/perseids-project/perseids-puppet/blob/master/site-modules/site/manifests/roles/annotation.pp) hosts a variety of tools, publications and services:

__marmotta (annotation.perseids.org)__: A graph/triple store providing the data store for annotations created by the Plokamos annotation tool and the Perseids Collections API.

__imgup (imgup.perseids.org)__: A Ruby on Rails tool for uploading images to Cite Collections. This is served by Apache via the mod_passenger module.

__jackson (jackson.perseids.org)__: A Ruby on Rails + Angular JS tool for managing Cite Collections of images. The back-end is served by Apache via the mod_passenger module and it writes to the Fuseki data store hosted on the services node.

__arethusa (arethusa.perseids.org)__: An Angular JS application providing a Treebank Annotation tool to the Perseids platform. It writes data to sosol via the api.

__arethusa_configs (arethusa-configs.perseids.org)__: A set of configuration files for the Arethusa tool. Served by Apache.

__joth (joth.perseids.org)__: Journey of The Hero Prototype Publication. (Fixed data set)

__pca (pca.perseids.org)__: Perseids Client Applications - python flask application providing a set of input forms for creating new annotation publications in Perseids.   Interactions with SoSOL, the LLT services, the Alpheios Editor, and Arethusa.

__pubs (pubs.perseids.org)__: various prototype publications, all static data sets.

__www (www[dot]perseids[dot]org)__: serves mainly proxies, rewrites and redirects. (The proxies are all defined in the puppet hiera config file data/common.yaml under site::profiles::www_proxy_paths)

## collections (collections.perseids.org)

The [collections node](https://github.com/perseids-project/perseids-puppet/blob/master/site-modules/site/manifests/roles/collections.pp) hosts the Perseids Manifold implementation of the RDA Collections API (https://github.com/rdACollectionsWG/perseids-manifold), a Python Flask application. It reads/writes to the Perseids marmotta datastore.

## morph (morph.perseids.org)

The [morph node](https://github.com/perseids-project/perseids-puppet/blob/master/site-modules/site/manifests/roles/morph.pp) hosts the Perseids implementation of the Tufts Morphology Service (https://github.com/perseids-project/morphsvc), a Python Flask application. It also hosts local versions of the Morpheus parser and uses a local Redis cache.

## hook (ci.perseids.org)
The [hook node](https://github.com/perseids-project/perseids-puppet/blob/master/site-modules/site/manifests/roles/hook.pp) hosts the continuous integration environment for Perseus CapiTainS texts.  See https://github.com/Capitains/Hook

## monitor (monitor.perseids.org)

The [monitor](https://github.com/perseids-project/perseids-puppet/blob/master/site-modules/site/manifests/roles/monitor.pp) hosts Icinga and the AWS orchestration client.

## digmill (digmill.perseids.org)

The [digmill node](https://github.com/perseids-project/perseids-puppet/blob/master/site-modules/site/manifests/roles/digmill.pp) hosts the Digital Milliet Flask Python Application. See http://digital-milliet.readthedocs.io/en/latest/.


## Node Dependencies

### SoSOL Node Dependencies

![SoSOL Node Dependencies](https://github.com/perseids-project/perseids-puppet/blob/master/doc/perseids_deployment_sosol.png)

### Services Node Dependencies
![Services Node Dependencies](https://github.com/perseids-project/perseids-puppet/blob/master/doc/perseids_deployment_services.png)

### Annotation Node Dependencies

![Annotation Node Dependencies](https://github.com/perseids-project/perseids-puppet/blob/master/doc/perseids_deployment_annotation.png)

### Collections, Morph, Hook and Monitor Node Dependencies

![Other Node Dependencies](https://github.com/perseids-project/perseids-puppet/blob/master/doc/perseids_deployment_other.png)

### Digmill Node Dependencies

![Digmill Node Dependencies](https://github.com/perseids-project/perseids-puppet/blob/master/doc/perseids_deployment_digmill.png)

## References

https://datascience.codata.org/articles/10.5334/dsj-2017-019/

https://github.com/perseids-project/perseids_docs/blob/master/integrations/syriaca/README.md



