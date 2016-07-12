require 'assert'
require 'dk-abdeploy'

module Dk::ABDeploy

  class UnitTests < Assert::Context
    desc "Dk::ABDeploy"
    setup do
      @deploy_module = Dk::ABDeploy
    end
    subject{ @deploy_module }

    should "know its dir/link names" do
      assert_equal 'shared',   subject::SHARED_DIR_NAME
      assert_equal 'releases', subject::RELEASES_DIR_NAME
      assert_equal 'A',        subject::RELEASE_A_DIR_NAME
      assert_equal 'B',        subject::RELEASE_B_DIR_NAME
      assert_equal 'current',  subject::CURRENT_LINK_NAME
    end

    should "know its param names" do
      assert_equal 'dk_abdeploy_root',          subject::ROOT_PARAM_NAME
      assert_equal 'dk_abdeploy_shared_dir',    subject::SHARED_DIR_PARAM_NAME
      assert_equal 'dk_abdeploy_releases_dir',  subject::RELEASES_DIR_PARAM_NAME
      assert_equal 'dk_abdeploy_release_a_dir', subject::RELEASE_A_DIR_PARAM_NAME
      assert_equal 'dk_abdeploy_release_b_dir', subject::RELEASE_B_DIR_PARAM_NAME
      assert_equal 'dk_abdeploy_repo',          subject::REPO_PARAM_NAME
    end

    should "know its ssh hosts group name" do
      assert_equal 'dk_abdeploy_servers', subject::SSH_HOSTS_GROUP_NAME
    end

  end

end
