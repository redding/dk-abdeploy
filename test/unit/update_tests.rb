require 'assert'
require 'dk-abdeploy/update'

require 'dk/task'
require 'dk/task_run'
require 'dk-abdeploy'
require 'test/support/validate'

class Dk::ABDeploy::Update

  class UnitTests < Assert::Context
    desc "Dk::ABDeploy::Update"
    setup do
      @task_class = Dk::ABDeploy::Update
    end
    subject{ @task_class }

    should "be a Dk::Task" do
      assert_includes Dk::Task, subject
    end

    should "know its description" do
      exp = "(dk-abdeploy) update the non-current release's source"
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
      @params.merge!({
        Dk::ABDeploy::REF_PARAM_NAME              => Factory.hex,
        Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME => "#{Factory.string}.example.com"
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
      @curr = @params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]
      @host = @params[Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME]

      @rl_cmd_str = readlink_cmd_str(@task, @curr, :host => @host)

      @curr_release_dir = Factory.path
      @runner.stub_cmd(@rl_cmd_str){ |spy| spy.stdout = @curr_release_dir }

      @runner.run
    end
    subject{ @runner }

    should "run the Validate task callback, 1 cmd and 1 ssh cmd" do
      assert_equal 3, subject.runs.size
    end

    should "run a readlink cmd over ssh to set the current release dir param" do
      _, readlink_cmd, _ = subject.runs

      assert_equal @rl_cmd_str, readlink_cmd.cmd_str

      exp = @curr_release_dir
      assert_equal exp, subject.params[Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME]
    end

    should "set the deploy release dir to the A dir by default" do
      exp = @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]
      assert_equal exp, subject.params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME]
    end

    should "set the deploy release dir to the non-current release dir" do
      # if current is A, set deploy to B
      curr_release_dir = @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]
      runner = test_runner(@task_class, :params => @params)
      runner.stub_cmd(@rl_cmd_str){ |spy| spy.stdout = curr_release_dir }
      runner.run

      exp = @params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
      assert_equal exp, runner.params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME]

      # if current is B, set deploy to A
      curr_release_dir = @params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
      runner = test_runner(@task_class, :params => @params)
      runner.stub_cmd(@rl_cmd_str){ |spy| spy.stdout = curr_release_dir }
      runner.run

      exp = @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]
      assert_equal exp, runner.params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME]
    end

    should "run an ssh cmd to reset the deploy release git repo" do
      _, _, git_reset_ssh = subject.runs
      repo_dir = @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]
      ref      = @params[Dk::ABDeploy::REF_PARAM_NAME]

      exp = git_reset_cmd_str(repo_dir, ref)
      assert_equal exp, git_reset_ssh.cmd_str
    end

    should "complain if the ref/host params aren't set" do
      value = [nil, ''].sample

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::REF_PARAM_NAME              => value,
        Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME => value
      })
      assert_raises(ArgumentError){ runner.run }

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::REF_PARAM_NAME              => Factory.path,
        Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME => value
      })
      assert_raises(ArgumentError){ runner.run }

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::REF_PARAM_NAME              => value,
        Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME => Factory.string
      })
      assert_raises(ArgumentError){ runner.run }
    end

    private

    def readlink_cmd_str(task, link, ssh_opts)
      ssh_cmd_str(task, "readlink #{link}", ssh_opts)
    end

    def git_reset_cmd_str(repo_dir, ref)
      "cd #{repo_dir} && " \
      "git fetch -q origin && " \
      "git reset -q --hard #{ref} && " \
      "git clean -q -d -x -f"
    end


  end

end
