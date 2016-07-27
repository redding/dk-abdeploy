require 'assert'
require 'dk-abdeploy/link'

require 'dk/task'
require 'dk/task_run'
require 'dk-abdeploy'
require 'test/support/validate'

class Dk::ABDeploy::Link

  class UnitTests < Assert::Context
    desc "Dk::ABDeploy::Link"
    setup do
      @task_class = Dk::ABDeploy::Link
    end
    subject{ @task_class }

    should "be a Dk task" do
      assert_includes Dk::Task, subject
    end

    should "know its description" do
      exp = "(dk-abdeploy) link the deploy release dir as the current dir"
      assert_equal exp, subject.description
    end

    should "run the Validate task as a before callback" do
      assert_equal [Dk::ABDeploy::Validate], subject.before_callback_task_classes
    end

  end

  class InitTests < UnitTests
    include Dk::ABDeploy::Validate::TestHelpers

    desc "when init"
    setup do
      release_dirs = [
        @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME],
        @params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
      ]
      @params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME] = release_dirs.sample

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

    should "run the Validate task callback and 1 ssh cmd" do
      assert_equal 2, subject.runs.size
    end

    should "run an ssh cmds to link the deploy release dir as the current dir" do
      _, link_ssh = subject.runs
      curr_dir    = @params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]
      release_dir = @params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME]

      exp = "rm -f #{curr_dir} && ln -s #{release_dir} #{curr_dir}"
      assert_equal exp, link_ssh.cmd_str
    end

    should "complain if the deploy release dir param isn't set" do
      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME => [nil, ''].sample
      })
      assert_raises(ArgumentError){ runner.run }
    end

  end

end
