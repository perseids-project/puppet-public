# Perseids Marmotta server
class site::profiles::marmotta {
  include marmotta
  include site::profiles::marmotta::backup
}
