require 'assert'
require 'dk-abdeploy/cleanup'

require 'dk/task'
require 'dk/task_run'
require 'dk-abdeploy'
require 'dk-abdeploy/update'
require 'test/support/validate'

class Dk::ABDeploy::Cleanup

  class UnitTests < Assert::Context
    desc "Dk::ABDeploy::Cleanup"
    setup do
      @task_class = Dk::ABDeploy::Cleanup
    end
    subject{ @task_class }

    should "be a Dk task" do
      assert_includes Dk::Task, subject
    end

    should "know its description" do
      exp = "(dk-abdeploy) update the non-deploy release's source post-update"
      assert_equal exp, subject.description
    end

    should "run the Validate task as a before callback" do
      assert_equal [Dk::ABDeploy::Validate], subject.before_callback_task_classes
    end

  end

  class InitTests < UnitTests
    include Dk::ABDeploy::Update::TestHelpers

    desc "when init"
    setup do
      @params.merge!({
        Dk::ABDeploy::REF_PARAM_NAME => Factory.hex,
      })
      @runner = test_runner(@task_class, :params => @params)
      @task = @runner.task
    end
    subject{ @task }

    should "know its ssh hosts" do
      assert_equal Dk::ABDeploy::SSH_HOSTS_GROUP_NAME, subject.dk_dsl_ssh_hosts
    end

  end

  class RunTests < InitTests
    desc "and run"
    setup do
      @runner.run
    end
    subject{ @runner }

    should "run the Validate callback and 1 ssh cmd" do
      assert_equal 2, subject.runs.size
    end

    should "run an ssh cmd to reset the current release git repo" do
      _, git_reset_ssh = subject.runs

      repo_dir = @params[Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME]
      ref      = @params[Dk::ABDeploy::REF_PARAM_NAME]
      exp      = Dk::ABDeploy::Update.git_reset_cmd_str(repo_dir, ref)
      assert_equal exp, git_reset_ssh.cmd_str
    end

    should "complain if the current release dir or ref params aren't set" do
      value = [nil, ''].sample

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::REF_PARAM_NAME                 => value,
        Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME => value
      })
      assert_raises(ArgumentError){ runner.run }

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::REF_PARAM_NAME                 => Factory.string,
        Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME => value
      })
      assert_raises(ArgumentError){ runner.run }

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::REF_PARAM_NAME                 => value,
        Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME => Factory.string
      })
      assert_raises(ArgumentError){ runner.run }
    end

  end

end
