module Dk; end
module Dk::ABDeploy; end
module Dk::ABDeploy::Utils

  module BundlerCmdStr

    def self.new(params, cmd_str, opts = nil)
      opts ||= {}

      opts[:root] ||= Dk::ABDeploy::CURRENT_DIR_PARAM_NAME
      opts[:env]  ||= ""

      cmd_root = params.key?(opts[:root]) ? params[opts[:root]] : opts[:root]

      "cd #{cmd_root} && #{opts[:env]} bundle exec #{cmd_str}"
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
