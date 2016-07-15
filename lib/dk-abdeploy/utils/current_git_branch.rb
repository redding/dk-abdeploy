module Dk; end
module Dk::ABDeploy; end
module Dk::ABDeploy::Utils

  module CurrentGitBranch

    def self.new(&block)
      git_cmd_str = "git symbolic-ref HEAD"

      # returns the cmd str if no block given
      return git_cmd_str if block.nil?

      # to get the value pass a block that runs the yielded cmd_str cmd, ex:
      # current_branch_name = CurrentGitBranch.new do |cmd_str|
      #   log_info "Fetching current git branch from HEAD"
      #   cmd! cmd_str
      # end
      cmd = block.call(git_cmd_str)
      cmd.stdout.split('/').last.strip
    end

  end

end
