# Manage AWS resources
class site::roles::aws_orchestrator {
  include ::site::profiles::common
  include ::site::profiles::aws_sdk
  include ::site::profiles::aws_credentials
  include ::site::profiles::aws_resources
}
