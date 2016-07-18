require 'much-plugin'
require 'dk/task'
require 'dk-abdeploy/test_helpers'
require 'dk-abdeploy/validate'

class Dk::ABDeploy::Validate

  module TestHelpers
    include MuchPlugin

    plugin_included do
      include Dk::Task::TestHelpers
      include Dk::ABDeploy::TestHelpers

      setup do
        set_dk_abdeploy_validate_params

        @root      = @dk_abdeploy_root
        @repo      = @dk_abdeploy_repo
        @shared    = @dk_abdeploy_shared
        @current   = @dk_abdeploy_current
        @releases  = @dk_abdeploy_releases
        @release_a = @dk_abdeploy_release_a
        @release_b = @dk_abdeploy_release_b
      end

    end

  end

end
