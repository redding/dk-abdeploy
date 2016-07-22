require 'assert'
require 'dk-abdeploy/utils/bundler_cmd_str'

module Dk::ABDeploy::Utils::BundlerCmdStr

  class UnitTests < Assert::Context
    desc "Dk::ABDeploy::Utils::BundlerCmdStr"
    setup do
      @params = {
        Dk::ABDeploy::CURRENT_DIR_PARAM_NAME   => Factory.path,
        Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME => Factory.path
      }
      @cmd_str = Factory.string

      @bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@cmd_str, @params)
    end
    subject{ @bundler_cmd_str }

    should "build a bundler cmd str to run" do
      assert_includes "&&  bundle #{@cmd_str}", subject
    end

    should "use dk-abdeploy's current dir param as the root param by default" do
      exp = "cd #{@params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]} &&"
      assert_includes exp, subject
    end

    should "use a custom root param if given" do
      bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@cmd_str, @params, {
        :root_param => Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME
      })

      exp = "cd #{@params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]} &&"
      assert_includes exp, bundler_cmd_str
    end

    should "use a custom env var string if given" do
      env = "#{Factory.string.upcase}=#{Factory.string}"
      bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@cmd_str, @params, {
        :env => env
      })

      assert_includes "&& #{env} bundle #{@cmd_str}", bundler_cmd_str
    end

  end

  class TestHelpersTests < UnitTests
    include TestHelpers

    desc "TestHelpers"
    setup do
      @context = Class.new{ include TestHelpers }.new
    end
    subject{ @context }

    should have_imeths :assert_bundler_cmd_str

    should "prove a util is a bundler cmd that was built correctly" do
      assert_bundler_cmd_str(@bundler_cmd_str, @cmd_str, @params)
      assert_bundler_cmd_str(@bundler_cmd_str, @cmd_str, @params, {
        :root_param => Dk::ABDeploy::CURRENT_DIR_PARAM_NAME
      })
      assert_bundler_cmd_str(@bundler_cmd_str, @cmd_str, @params, :env => '')

      env = "#{Factory.string.upcase}=#{Factory.string}"
      bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@cmd_str, @params, {
        :root_param => Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME,
        :env        => env
      })
      assert_bundler_cmd_str(bundler_cmd_str, @cmd_str, @params, {
        :root_param => Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME,
        :env        => env
      })
    end

  end

end
