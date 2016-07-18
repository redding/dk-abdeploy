require 'dk/task'
require 'dk-abdeploy/validate'
require 'dk-abdeploy'

module Dk::ABDeploy

  class Update
    include Dk::Task

    desc "(dk-abdeploy) update the non-current release's source"

    before Validate

    ssh_hosts SSH_HOSTS_GROUP_NAME

    def run!
      # validate required params are set
      if params[REF_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{REF_PARAM_NAME.inspect} param set"
      end
      if params[PRIMARY_SSH_HOST_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{PRIMARY_SSH_HOST_PARAM_NAME.inspect} param set"
      end

      # lookup the current release dir; set current/deploy release dir params
      rl_cmd = cmd readlink_cmd_str(params[CURRENT_DIR_PARAM_NAME], {
        :host => params[PRIMARY_SSH_HOST_PARAM_NAME]
      })
      set_param(CURRENT_RELEASE_DIR_PARAM_NAME, rl_cmd.stdout.strip)

      release_dirs = [
        params[RELEASE_A_DIR_PARAM_NAME],
        params[RELEASE_B_DIR_PARAM_NAME]
      ]
      release_dirs.delete(params[CURRENT_RELEASE_DIR_PARAM_NAME])
      set_param(DEPLOY_RELEASE_DIR_PARAM_NAME, release_dirs.first)

      # reset the deploy release git repo
      ssh! git_reset_cmd_str(params[DEPLOY_RELEASE_DIR_PARAM_NAME], params[REF_PARAM_NAME])
    end

    private

    def readlink_cmd_str(link, ssh_opts)
      ssh_cmd_str("readlink #{link}", ssh_opts)
    end

    def git_reset_cmd_str(repo_dir, ref)
      "cd #{repo_dir} && " \
      "git fetch -q origin && " \
      "git reset -q --hard #{ref} && " \
      "git clean -q -d -x -f"
    end

  end

end
