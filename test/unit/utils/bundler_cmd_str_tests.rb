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

      @bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@params, @cmd_str)
    end
    subject{ @bundler_cmd_str }

    should "build a bundler cmd str to run" do
      assert_includes "&&  bundle exec #{@cmd_str}", subject
    end

    should "use dk-abdeploy's current dir param as the root path by default" do
      exp = "cd #{@params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]} &&"
      assert_includes exp, subject
    end

    should "use a custom root path if given" do
      path = Factory.path
      bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@params, @cmd_str, {
        :root => path
      })
      assert_includes "cd #{path} &&", bundler_cmd_str
    end

    should "use a custom param as the root path if given" do
      bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@params, @cmd_str, {
        :root => Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME
      })

      exp = "cd #{@params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]} &&"
      assert_includes exp, bundler_cmd_str
    end

    should "use a custom env var string if given" do
      env = "#{Factory.string.upcase}=#{Factory.string}"
      bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@params, @cmd_str, {
        :env => env
      })

      assert_includes "&& #{env} bundle exec #{@cmd_str}", bundler_cmd_str
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
      assert_bundler_cmd_str(@bundler_cmd_str, @params, @cmd_str)
      assert_bundler_cmd_str(@bundler_cmd_str, @params, @cmd_str, {
        :root => Dk::ABDeploy::CURRENT_DIR_PARAM_NAME
      })
      assert_bundler_cmd_str(@bundler_cmd_str, @params, @cmd_str, {
        :root => @params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]
      })
      assert_bundler_cmd_str(@bundler_cmd_str, @params, @cmd_str, :env => '')

      env = "#{Factory.string.upcase}=#{Factory.string}"
      bundler_cmd_str = Dk::ABDeploy::Utils::BundlerCmdStr.new(@params, @cmd_str, {
        :root => Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME,
        :env  => env
      })
      assert_bundler_cmd_str(bundler_cmd_str, @params, @cmd_str, {
        :root => Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME,
        :env  => env
      })
    end

  end

end
