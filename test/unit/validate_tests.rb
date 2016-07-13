require 'assert'
require 'dk-abdeploy/validate'

require 'dk/task'
require 'dk-abdeploy'

class Dk::ABDeploy::Validate

  class UnitTests < Assert::Context
    desc "Dk::ABDeploy::Validate"
    setup do
      @task_class = Dk::ABDeploy::Validate
    end
    subject{ @task_class }

    should "be a Dk::Task" do
      assert_includes Dk::Task, subject
    end

    should "know its description" do
      exp = "(dk-abdeploy) validate the required dk-abdeploy params"
      assert_equal exp, subject.description
    end

  end

  class RunTests < UnitTests
    include Dk::Task::TestHelpers

    desc "when run"
    setup do
      @root = Factory.path
      @repo = Factory.string
      @params = {
        Dk::ABDeploy::ROOT_PARAM_NAME => @root,
        Dk::ABDeploy::REPO_PARAM_NAME => @repo
      }
      @runner = test_runner(@task_class, :params => @params)
      @runner.run
    end
    subject{ @runner }

    should "set some params based on the root param" do
      exp = File.join(@root, Dk::ABDeploy::SHARED_DIR_NAME)
      assert_equal exp, subject.params[Dk::ABDeploy::SHARED_DIR_PARAM_NAME]

      exp = File.join(@root, Dk::ABDeploy::RELEASES_DIR_NAME)
      assert_equal exp, subject.params[Dk::ABDeploy::RELEASES_DIR_PARAM_NAME]

      exp_releases_dir = exp

      exp = File.join(exp_releases_dir, Dk::ABDeploy::RELEASE_A_DIR_NAME)
      assert_equal exp, subject.params[Dk::ABDeploy::RELEASE_A_DIR_PARAM_NAME]

      exp = File.join(exp_releases_dir, Dk::ABDeploy::RELEASE_B_DIR_NAME)
      assert_equal exp, subject.params[Dk::ABDeploy::RELEASE_B_DIR_PARAM_NAME]
    end

    should "complain if the root/repo params aren't set" do
      value = [nil, ''].sample

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::ROOT_PARAM_NAME => value,
        Dk::ABDeploy::REPO_PARAM_NAME => value
      })
      assert_raises(ArgumentError){ runner.run }

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::ROOT_PARAM_NAME => Factory.path,
        Dk::ABDeploy::REPO_PARAM_NAME => value
      })
      assert_raises(ArgumentError){ runner.run }

      runner = test_runner(@task_class, :params => {
        Dk::ABDeploy::ROOT_PARAM_NAME => value,
        Dk::ABDeploy::REPO_PARAM_NAME => Factory.string
      })
      assert_raises(ArgumentError){ runner.run }
    end

  end

end
