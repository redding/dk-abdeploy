require 'much-plugin'
require 'dk/task'
require "dk-abdeploy/constants"
require "dk-abdeploy/update"
require 'dk-abdeploy/validate'

module Dk::ABDeploy

  class Cleanup
    include Dk::Task

    desc "(dk-abdeploy) update the non-deploy release's source post-update"

    before Validate

    ssh_hosts SSH_HOSTS_GROUP_NAME

    def run!
      # current release dir is the one that was current pre-update - the
      # non-deploy release dir
      if params[CURRENT_RELEASE_DIR_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{CURRENT_RELEASE_DIR_PARAM_NAME.inspect} param set"
      end
      if params[REF_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{REF_PARAM_NAME.inspect} param set"
      end

      # reset the non-deploy release git repo
      ssh! git_reset_cmd_str(params[CURRENT_RELEASE_DIR_PARAM_NAME], params[REF_PARAM_NAME])
    end

    private

    def git_reset_cmd_str(repo_dir, ref)
      Update.git_reset_cmd_str(repo_dir, ref)
    end

  end

end
