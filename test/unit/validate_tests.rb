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

    should "run only once" do
      assert_true subject.run_only_once
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

      @hosts = Factory.integer(3).times.map{ Factory.string }
      @runner.ssh_hosts(Dk::ABDeploy::SSH_HOSTS_GROUP_NAME, @hosts)

      @runner.run
    end
    subject{ @runner }

    should "set some params based on the root param" do
      exp = File.join(@root, Dk::ABDeploy::SHARED_DIR_NAME)
      assert_equal exp, subject.params[Dk::ABDeploy::SHARED_DIR_PARAM_NAME]

      exp = File.join(@root, Dk::ABDeploy::CURRENT_LINK_NAME)
      assert_equal exp, subject.params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME]

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

      @params[@params.keys.sample] = value
      runner = test_runner(@task_class, :params => @params)
      assert_raises(ArgumentError){ runner.run }
    end

    should "complain if the ssh hosts aren't set" do
      runner = test_runner(@task_class, :params => @params)
      assert_raises(ArgumentError){ runner.run }
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
        include Dk::ABDeploy::Validate::TestHelpers
        attr_reader :dk_abdeploy_root, :dk_abdeploy_repo
        attr_reader :dk_abdeploy_shared, :dk_abdeploy_current
        attr_reader :dk_abdeploy_releases
        attr_reader :dk_abdeploy_release_a, :dk_abdeploy_release_b
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

    should "setup the ivars and params the validate task does" do
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

  end

end
