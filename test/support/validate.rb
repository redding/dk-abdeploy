require 'much-plugin'
require 'dk/task'
require 'dk-abdeploy/validate'

class Dk::ABDeploy::Validate

  module TestHelpers
    include MuchPlugin

    plugin_included do
      include Dk::Task::TestHelpers

      setup do
        @root      = Factory.path
        @repo      = Factory.string
        @shared    = File.join(@root,     Dk::ABDeploy::SHARED_DIR_NAME)
        @releases  = File.join(@root,     Dk::ABDeploy::RELEASES_DIR_NAME)
        @release_a = File.join(@releases, Dk::ABDeploy::RELEASE_A_DIR_NAME)
        @release_b = File.join(@releases, Dk::ABDeploy::RELEASE_B_DIR_NAME)

        @params = {
          Dk::ABDeploy::ROOT_PARAM_NAME          => @root,
          Dk::ABDeploy::REPO_PARAM_NAME          => @repo,
          Dk::ABDeploy::SHARED_DIR_PARAM_NAME    => @shared,
          Dk::ABDeploy::RELEASES_DIR_PARAM_NAME  => @releases,
          Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME => @release_a,
          Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME => @release_b
        }
      end

    end

  end

end
