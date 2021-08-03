class role::kubecluster::dev {
  include profile::base
  include profile::docker
  include profile::developer_tools
}
