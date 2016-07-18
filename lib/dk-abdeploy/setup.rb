require 'dk/task'
require "dk-abdeploy/constants"
require 'dk-abdeploy/validate'

module Dk::ABDeploy

  class Setup
    include Dk::Task

    desc "(dk-abdeploy) create the dirs and clone the repos for the A/B deploy scheme"

    before Validate

    ssh_hosts SSH_HOSTS_GROUP_NAME

    def run!
      # make the expected dirs if not already made
      mkdirs = [
        params[ROOT_PARAM_NAME].to_s,
        params[SHARED_DIR_PARAM_NAME],
        params[RELEASES_DIR_PARAM_NAME],
        params[RELEASE_A_DIR_PARAM_NAME],
        params[RELEASE_B_DIR_PARAM_NAME]
      ]
      ssh! "mkdir -p #{mkdirs.join(' ')}"

      # clone the A/B release repos if not already cloned
      ssh! clone_cmd_str(params[REPO_PARAM_NAME], params[RELEASE_A_DIR_PARAM_NAME])
      ssh! clone_cmd_str(params[REPO_PARAM_NAME], params[RELEASE_B_DIR_PARAM_NAME])
    end

    private

    def clone_cmd_str(repo, release_dir)
      "if [ -d #{release_dir}/.git ]; " \
      "then echo 'git repo already cloned to #{release_dir}'; " \
      "else git clone -q  #{repo} #{release_dir}; " \
      "fi"
    end

  end

end
