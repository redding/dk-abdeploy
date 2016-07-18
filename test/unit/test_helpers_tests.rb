require 'assert'
require 'dk-abdeploy/test_helpers'

require 'much-plugin'
require 'dk-abdeploy'

module Dk::ABDeploy::TestHelpers

  class UnitTests < Assert::Context
    desc "Dk::ABDeploy::TestHelpers"
    setup do
      @context_class = Class.new do
        include Dk::ABDeploy::TestHelpers
        attr_reader :dk_abdeploy_root, :dk_abdeploy_repo
        attr_reader :dk_abdeploy_shared, :dk_abdeploy_current
        attr_reader :dk_abdeploy_releases
        attr_reader :dk_abdeploy_release_a, :dk_abdeploy_release_b
        attr_reader :params
      end
      @context = @context_class.new
    end
    subject{ @context }

    should "use much-plugin" do
      assert_includes MuchPlugin, @context_class
    end

    should "setup the ivars and params the validate task does" do
      subject.set_dk_abdeploy_validate_params

      exp = subject.dk_abdeploy_root
      assert_equal exp, subject.params[Dk::ABDeploy::ROOT_PARAM_NAME]

      exp = subject.dk_abdeploy_repo
      assert_equal exp, subject.params[Dk::ABDeploy::REPO_PARAM_NAME]

      exp = subject.dk_abdeploy_shared
      assert_equal exp, subject.params[Dk::ABDeploy::SHARED_DIR_PARAM_NAME]

      exp = subject.dk_abdeploy_current
      assert_equal exp, subject.params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]

      exp = subject.dk_abdeploy_releases
      assert_equal exp, subject.params[Dk::ABDeploy::RELEASES_DIR_PARAM_NAME]

      exp = subject.dk_abdeploy_release_a
      assert_equal exp, subject.params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]

      exp = subject.dk_abdeploy_release_b
      assert_equal exp, subject.params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
    end

    should "setup the params the update task does" do
      subject.set_dk_abdeploy_validate_params
      subject.set_dk_abdeploy_update_params

      exp_release_dirs = [
        subject.params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME],
        subject.params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
      ]

      exp_release_dirs.delete(
        subject.params[Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME]
      )
      assert_equal 1, exp_release_dirs.size

      exp = exp_release_dirs.first
      assert_equal exp, subject.params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME]
    end

  end

end
