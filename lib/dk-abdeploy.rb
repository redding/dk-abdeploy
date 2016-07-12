require "dk-abdeploy/version"

module Dk; end
module Dk::ABDeploy

  SHARED_DIR_NAME    = 'shared'.freeze
  RELEASES_DIR_NAME  = 'releases'.freeze
  RELEASE_A_DIR_NAME = 'A'.freeze
  RELEASE_B_DIR_NAME = 'B'.freeze
  CURRENT_LINK_NAME  = 'current'.freeze

  ROOT_PARAM_NAME          = 'dk_abdeploy_root'.freeze
  SHARED_DIR_PARAM_NAME    = 'dk_abdeploy_shared_dir'.freeze
  RELEASES_DIR_PARAM_NAME  = 'dk_abdeploy_releases_dir'.freeze
  RELEASE_A_DIR_PARAM_NAME = 'dk_abdeploy_release_a_dir'.freeze
  RELEASE_B_DIR_PARAM_NAME = 'dk_abdeploy_release_b_dir'.freeze
  REPO_PARAM_NAME          = 'dk_abdeploy_repo'.freeze

  SSH_HOSTS_GROUP_NAME = 'dk_abdeploy_servers'.freeze

end
