require 'dk/task'
require "dk-abdeploy/constants"
require 'dk-abdeploy/validate'

module Dk::ABDeploy

  class Link
    include Dk::Task

    desc "(dk-abdeploy) link the deploy release dir as the current dir"

    before Validate

    ssh_hosts SSH_HOSTS_GROUP_NAME

    def run!
      # validate required params are set
      if params[DEPLOY_RELEASE_DIR_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{DEPLOY_RELEASE_DIR_PARAM_NAME.inspect} param set"
      end

      # link the deploy release dir as the current dir
      curr_dir    = params[CURRENT_DIR_PARAM_NAME]
      release_dir = params[DEPLOY_RELEASE_DIR_PARAM_NAME]
      ssh! "rm -f #{curr_dir} && ln -s #{release_dir} #{curr_dir}"
    end

  end

end
