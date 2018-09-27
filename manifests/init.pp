# == Class: springboot
#
# This module manages springboot applications, installing them from Nexus
# and running them as a service
#
# Parameters:
#  - $group: Maven group name
#  - $artifact: Maven artifact name
#  - $version: Maven version number
#  - $repository: Nexus repository name
#  - $env: list of environmental variable to set
#
#
# Actions:
#  - install application
#  - run application as service
#
# Requires: see Metadata.json
#
# Sample Usage:
#
class springboot (
  $group,
  $artifact,
  $version,
  $repository,
  $env
) {
  include ::nexus

  realize(User[spring], Group[spring])

  nexus::artifact { 'application' :
    group     => $group,
    artifact  => $artifact,
    version   => $version,
    repo      => $repository,
    extension => 'jar',
    location  => "/opt/${artifact}.jar",
    before    =>  Service[$artifact],
  }

  class { 'springboot::service':
    artifact => $artifact,
    env      => $env,
  }
}
