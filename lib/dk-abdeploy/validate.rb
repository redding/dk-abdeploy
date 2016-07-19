require 'much-plugin'
require 'pathname'
require 'dk/task'
require "dk-abdeploy/constants"

module Dk::ABDeploy

  class Validate
    include Dk::Task

    desc "(dk-abdeploy) validate the required dk-abdeploy params"

    run_only_once true

    def run!
      # validate required params are set
      if params[ROOT_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{ROOT_PARAM_NAME.inspect} param set"
      end
      if params[REPO_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{REPO_PARAM_NAME.inspect} param set"
      end

      # make sure the hosts group has been set
      if (h = ssh_hosts(SSH_HOSTS_GROUP_NAME)).nil? || h.empty?
        raise ArgumentError, "no #{SSH_HOSTS_GROUP_NAME.inspect} have been set"
      end

      # set common required params for downstream tasks
      deploy_root = Pathname.new(params[ROOT_PARAM_NAME])
      set_param(SHARED_DIR_PARAM_NAME,  deploy_root.join(SHARED_DIR_NAME).to_s)
      set_param(CURRENT_DIR_PARAM_NAME, deploy_root.join(CURRENT_LINK_NAME).to_s)

      releases_dir = deploy_root.join(RELEASES_DIR_NAME)
      set_param(RELEASES_DIR_PARAM_NAME,  releases_dir.to_s)
      set_param(RELEASE_A_DIR_PARAM_NAME, releases_dir.join(RELEASE_A_DIR_NAME).to_s)
      set_param(RELEASE_B_DIR_PARAM_NAME, releases_dir.join(RELEASE_B_DIR_NAME).to_s)
    end

    module TestHelpers
      include MuchPlugin

      plugin_included do
        include Dk::Task::TestHelpers

        setup do
          @dk_abdeploy_root ||= Factory.path
          @dk_abdeploy_repo ||= Factory.string

          @dk_abdeploy_shared ||= File.join(
            @dk_abdeploy_root,
            Dk::ABDeploy::SHARED_DIR_NAME
          )
          @dk_abdeploy_current ||= File.join(
            @dk_abdeploy_root,
            Dk::ABDeploy::CURRENT_LINK_NAME
          )
          @dk_abdeploy_releases ||= File.join(
            @dk_abdeploy_root,
            Dk::ABDeploy::RELEASES_DIR_NAME
          )
          @dk_abdeploy_release_a ||= File.join(
            @dk_abdeploy_releases,
            Dk::ABDeploy::RELEASE_A_DIR_NAME
          )
          @dk_abdeploy_release_b ||= File.join(
            @dk_abdeploy_releases,
            Dk::ABDeploy::RELEASE_B_DIR_NAME
          )

          @params ||= {}
          @params[Dk::ABDeploy::ROOT_PARAM_NAME]          ||= @dk_abdeploy_root
          @params[Dk::ABDeploy::REPO_PARAM_NAME]          ||= @dk_abdeploy_repo
          @params[Dk::ABDeploy::SHARED_DIR_PARAM_NAME]    ||= @dk_abdeploy_shared
          @params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]   ||= @dk_abdeploy_current
          @params[Dk::ABDeploy::RELEASES_DIR_PARAM_NAME]  ||= @dk_abdeploy_releases
          @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME] ||= @dk_abdeploy_release_a
          @params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME] ||= @dk_abdeploy_release_b
        end

      end

    end

  end

end
