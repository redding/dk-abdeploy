require 'assert'
require 'dk-abdeploy/utils/current_git_branch'

require 'dk/task'

module Dk::ABDeploy::Utils::CurrentGitBranch

  class UnitTests < Assert::Context
    include Dk::Task::TestHelpers

    desc "Dk::ABDeploy::Utils::CurrentGitBranch"
    setup do
      @current_git_branch = Dk::ABDeploy::Utils::CurrentGitBranch
    end
    subject{ @current_git_branch }

    should "return the cmd str to lookup the current git branch if no block given" do
      assert_equal "git symbolic-ref HEAD", subject.new
    end

    should "yield the cmd str and expect a local cmd obj returned if a block given" do
      task_class = Class.new do
        include Dk::Task

        def run!
          ref = Dk::ABDeploy::Utils::CurrentGitBranch.new{ |cmd_str| cmd! cmd_str }
          set_param 'git_ref', ref
        end
      end
      runner = test_runner(task_class)

      branch_name = Factory.string
      runner.stub_cmd(subject.new){ |spy| spy.stdout = "refs/heads/#{branch_name}" }
      runner.run

      assert_equal branch_name, runner.params['git_ref']
    end

  end

end
