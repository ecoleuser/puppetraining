class role::my-role {
  include profile::apache
  include profile::base  # All roles should have the base profile
}
