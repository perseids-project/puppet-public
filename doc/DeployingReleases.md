# Deploying Perseids Releases via Puppet

Almost all of the Perseids tools, applications and services should be deployed via updates to the release versions identified 
in the puppet repository's hiera file.

## Hiera-Deployed Apps

The following settings are used:

| Application | Release Version Hiera Setting | Expected Value | Source URL Hiera Setting |
| ----------- | ------------- | -------------- | -------- | 
| SoSOL | sosol::release_version | Git tag/branch | sosol::app_repo |
| Annotation Editor | sosol::annotation_editor::release_version | Git tag/branchname| sosol::annotation_editor::git_url |
| Arethusa | arethusa::app_version | Git tag/branch | arethusa::app_repo | 
| Alignment Editor | sosol::alignment_editor_url | url to download zip of source from GitHub | N/A |
| JackSON | jackson::revision | Git tag/branch | jackson::git_url |
| ImgUp | imgup::revision | Git tag/branch | imgup::git_url |
| Morphology Service | morphology::release_version | Git tag/branch | morphology::repos |
| Morpheus (Alpheios) | morpheus::alpheios_src_tag | Git tag/branch | morpheus::alpheios_git_url |
| Morpheus (Perseus) | morpheus::perseus_src_tag | Git tag/branch | morpheus::perseus_git_url |
| Morpheus (Stemlibs) | morpheus::stemlibs_src_tag | Git tag/branch | morpheus::latin_stemlibs_git_url |
| Collections Service | collections::release_version | Git tag/branch | collections::repos | 
| Digital Milliet | digmill::app_version | Git tag/branch| digmil::repo_url |
| Perseids Client Apps | pca::app_release | Git tag/branch | pca::source_repo | 
| Hook | hook::app_version | Git tag/branch | hook::app_repo | 
| Flask GitHub Proxy | fgh::app_revision | Git tag/branch | fgh::app_repo |
| Cite Fusion Collection Service | citefusioncoll::app_version | Git tag/branch | citefusioncoll::app_repo | 
| SG Reader | sg::app_version | Git tag/branch | sg::app_repo |
| LLT | llt::app_version | Git tag/branch | llt::app_repo | 
| Journey of the Hero Prototype| joth::source_version | Git tag/branch | joth::source_repo |

## Configuration Changes

Occasionally, configuration changes for the Perseids apps may require updates to puppet templates.  The most common of these is the addition of new proxied repositories to the Flask GitHub Proxy Setup.  This process is described at https://github.com/perseids-project/perseids_docs/blob/master/admin.md#enabling-a-new-github-pass-through-community.

## Exceptions

### CapiTainS and Plokamos

The __CapiTainS__ (Nemo and Nautilus) service (cts.perseids.org) is deployed from PyPi, and the release versions are managed
via the dependencies in the app.py.rb puppet template : `site_modules/capitains/templates/requirements.py3.txt.erb`. Deploying a new version requires updating this template.  The __Plokamos__ release version used is embedded in the dependency for the __perseus_nemo_ui__ version. I.e. a new release of perseus_nemo_ui gets tagged, and it contains in its requirements.txt the release version of the nemo_plokamos_plugin.

### Publication Prototypes

There is a set of publication protypes which are deployed directly from the `master` branch of GitHub.  The GitHub urls for these applications are defined in the `pubs::vcsapps` Hiera setting (a map of publication names and their source urls).

