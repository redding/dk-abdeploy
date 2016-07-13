require 'assert'
require 'dk-abdeploy/setup'

require 'dk/task'
require 'dk/task_run'
require 'dk-abdeploy'
require 'test/support/validate'

class Dk::ABDeploy::Setup

  class UnitTests < Assert::Context
    desc "Dk::ABDeploy::Setup"
    setup do
      @task_class = Dk::ABDeploy::Setup
    end
    subject{ @task_class }

    should "be a Dk::Task" do
      assert_includes Dk::Task, subject
    end

    should "know its description" do
      exp = "(dk-abdeploy) create the dirs and clone the repos for the A/B deploy scheme"
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

    should "run the Validate task callback and 3 ssh cmds" do
      assert_equal 4, subject.runs.size
    end

    should "run ssh cmds to make the dirs and clone the A/B repos" do
      _, mkdir_ssh, clone_a_ssh, clone_b_ssh = subject.runs

      exp = "mkdir -p #{@root} #{@shared} #{@releases} #{@release_a} #{@release_b}"
      assert_equal exp, mkdir_ssh.cmd_str

      exp = clone_cmd(@repo, @release_a)
      assert_equal exp, clone_a_ssh.cmd_str

      exp = clone_cmd(@repo, @release_b)
      assert_equal exp, clone_b_ssh.cmd_str
    end

    private

    def clone_cmd(repo, release_dir)
      "if [ -d #{release_dir}/.git ]; " \
      "then echo 'git repo already cloned to #{release_dir}'; " \
      "else git clone -q  #{repo} #{release_dir}; " \
      "fi"
    end

  end

end
