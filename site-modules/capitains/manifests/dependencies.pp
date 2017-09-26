# Dependencies for Capitains
class capitains::dependencies {
  include site::profiles::python3
  class { 'redis': }
  ensure_packages(hiera('capitains::deps'))
}
