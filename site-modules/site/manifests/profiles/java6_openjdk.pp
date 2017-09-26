# A profile to include Java 6 Open JDK
class site::profiles::java6_openjdk {
  class { 'java':
    package => 'openjdk-6-jdk',
  }
}
