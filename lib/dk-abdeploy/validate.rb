require 'pathname'
require 'dk/task'
require 'dk-abdeploy'

module Dk::ABDeploy

  class Validate
    include Dk::Task

    desc "(dk-abdeploy) validate the required dk-abdeploy params"

    def run!
      # validate required params are set
      if params[ROOT_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{ROOT_PARAM_NAME.inspect} param set"
      end
      if params[REPO_PARAM_NAME].to_s.empty?
        raise ArgumentError, "no #{REPO_PARAM_NAME.inspect} param set"
      end

      # set common required params for downstream tasks
      deploy_root = Pathname.new(params[ROOT_PARAM_NAME])
      set_param(SHARED_DIR_PARAM_NAME,  deploy_root.join(SHARED_DIR_NAME).to_s)
      set_param(CURRENT_DIR_PARAM_NAME, deploy_root.join(CURRENT_LINK_NAME).to_s)

      releases_dir = deploy_root.join(RELEASES_DIR_NAME)
      set_param(RELEASES_DIR_PARAM_NAME,  releases_dir.to_s)
      set_param(RELEASE_A_DIR_PARAM_NAME, releases_dir.join(RELEASE_A_DIR_NAME).to_s)
      set_param(RELEASE_B_DIR_PARAM_NAME, releases_dir.join(RELEASE_B_DIR_NAME).to_s)
    end

  end

end
