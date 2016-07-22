require 'dk-abdeploy/constants'

module Dk; end
module Dk::ABDeploy; end
module Dk::ABDeploy::Utils

  module BundlerCmdStr

    def self.new(cmd_str, params, opts = nil)
      opts ||= {}

      opts[:root_param] ||= Dk::ABDeploy::CURRENT_DIR_PARAM_NAME
      opts[:env]        ||= ""

      "cd #{params[opts[:root_param]]} && #{opts[:env]} bundle #{cmd_str}"
    end

    module TestHelpers

      def assert_bundler_cmd_str(bundler_cmd_str, *args)
        with_backtrace(caller) do
          exp = BundlerCmdStr.new(*args)
          assert_equal exp, bundler_cmd_str
        end
      end

    end

  end

end
