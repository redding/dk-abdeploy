require 'much-plugin'

module Dk::ABDeploy

  module TestHelpers
    include MuchPlugin

    plugin_included do
      include InstanceMethods

    end

    module InstanceMethods

      def set_dk_abdeploy_validate_params
        @dk_abdeploy_root = Factory.path
        @dk_abdeploy_repo = Factory.string

        @dk_abdeploy_shared = File.join(
          @dk_abdeploy_root,
          Dk::ABDeploy::SHARED_DIR_NAME
        )
        @dk_abdeploy_current = File.join(
          @dk_abdeploy_root,
          Dk::ABDeploy::CURRENT_LINK_NAME
        )
        @dk_abdeploy_releases = File.join(
          @dk_abdeploy_root,
          Dk::ABDeploy::RELEASES_DIR_NAME
        )
        @dk_abdeploy_release_a = File.join(
          @dk_abdeploy_releases,
          Dk::ABDeploy::RELEASE_A_DIR_NAME
        )
        @dk_abdeploy_release_b = File.join(
          @dk_abdeploy_releases,
          Dk::ABDeploy::RELEASE_B_DIR_NAME
        )

        @params ||= {}
        @params.merge!({
          Dk::ABDeploy::ROOT_PARAM_NAME          => @dk_abdeploy_root,
          Dk::ABDeploy::REPO_PARAM_NAME          => @dk_abdeploy_repo,
          Dk::ABDeploy::SHARED_DIR_PARAM_NAME    => @dk_abdeploy_shared,
          Dk::ABDeploy::CURRENT_DIR_PARAM_NAME   => @dk_abdeploy_current,
          Dk::ABDeploy::RELEASES_DIR_PARAM_NAME  => @dk_abdeploy_releases,
          Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME => @dk_abdeploy_release_a,
          Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME => @dk_abdeploy_release_b
        })
      end

      def set_dk_abdeploy_update_params
        release_dirs = [
          @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME],
          @params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
        ]

        @params[Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME] = release_dirs.sample
        release_dirs.delete(@params[Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME])
        @params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME] = release_dirs.first
      end

    end

  end

end
