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

    should have_imeths :readlink_cmd_str, :git_reset_cmd_str

    should "be a Dk task" do
      assert_includes Dk::Task, subject
    end

    should "know its description" do
      exp = "(dk-abdeploy) update the non-current release's source"
      assert_equal exp, subject.description
    end

    should "run the Validate task as a before callback" do
      assert_equal [Dk::ABDeploy::Validate], subject.before_callback_task_classes
    end

    should "build readlink cmd strs" do
      link = Factory.path

      exp = "readlink #{link}"
      assert_equal exp, subject.readlink_cmd_str(link)
    end

    should "build git reset cmd strs" do
      repo_dir = Factory.path
      ref      = Factory.string

      exp = "cd #{repo_dir} && " \
            "git fetch -q origin && " \
            "git reset -q --hard #{ref} && " \
            "git clean -q -d -x -f"
      assert_equal exp, subject.git_reset_cmd_str(repo_dir, ref)
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
      @curr_link  = @params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]
      @rl_cmd_str = @task_class.readlink_cmd_str(@curr_link)

      @runner.run
    end
    subject{ @runner }

    should "run the Validate task callback, 1 cmd and 1 ssh cmd" do
      assert_equal 3, subject.runs.size
    end

    should "run a readlink ssh to set or default the current release dir param" do
      _, rl_ssh, _ = subject.runs

      exp = @task_class.readlink_cmd_str(@params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME])
      assert_equal exp, rl_ssh.cmd_str
      exp = [@params[Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME]]
      assert_equal exp, rl_ssh.cmd_opts[:hosts]
    end

    should "set the current release dir param or default it to the B dir if none" do
      curr_release_dir = Factory.path
      runner = test_runner(@task_class, :params => @params)
      runner.stub_ssh(@rl_cmd_str, {
        :hosts => @params[Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME]
      }){ |spy| spy.stdout = curr_release_dir }
      runner.run
      exp = curr_release_dir
      assert_equal exp, runner.params[Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME]

      runner = test_runner(@task_class, :params => @params)
      runner.stub_ssh(@rl_cmd_str, {
        :hosts => @params[Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME]
      }){ |spy| spy.stdout = '' }
      runner.run
      exp = @params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
      assert_equal exp, runner.params[Dk::ABDeploy::CURRENT_RELEASE_DIR_PARAM_NAME]
    end

    should "set the deploy release dir to the A dir by default" do
      exp = @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]
      assert_equal exp, subject.params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME]
    end

    should "set the deploy release dir to the non-current release dir" do
      # if current is A, set deploy to B
      curr_release_dir = @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]
      runner = test_runner(@task_class, :params => @params)
      runner.stub_ssh(@rl_cmd_str, {
        :hosts => @params[Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME]
      }){ |spy| spy.stdout = curr_release_dir }
      runner.run

      exp = @params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
      assert_equal exp, runner.params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME]

      # if current is B, set deploy to A
      curr_release_dir = @params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
      runner = test_runner(@task_class, :params => @params)
      runner.stub_ssh(@rl_cmd_str, {
        :hosts => @params[Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME]
      }){ |spy| spy.stdout = curr_release_dir }
      runner.run

      exp = @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]
      assert_equal exp, runner.params[Dk::ABDeploy::DEPLOY_RELEASE_DIR_PARAM_NAME]
    end

    should "run an ssh cmd to reset the deploy release git repo" do
      _, _, git_reset_ssh = subject.runs
      repo_dir = @params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]
      ref      = @params[Dk::ABDeploy::REF_PARAM_NAME]

      exp = @task_class.git_reset_cmd_str(repo_dir, ref)
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
        Dk::ABDeploy::REF_PARAM_NAME              => Factory.string,
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

  end

  class TestHelpersTests < UnitTests
    desc "TestHelpers"
    setup do
      @context_class = Class.new do
        def self.setup_blocks; @setup_blocks ||= []; end
        def self.setup(&block)
          self.setup_blocks << block
        end
        include Dk::ABDeploy::Update::TestHelpers
        attr_reader :params
        def initialize
          self.class.setup_blocks.each{ |b| self.instance_eval(&b) }
        end
      end
      @context = @context_class.new
    end
    subject{ @context }

    should "use much-plugin" do
      assert_includes MuchPlugin, @context_class
    end

    should "setup the params the update task does" do
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
