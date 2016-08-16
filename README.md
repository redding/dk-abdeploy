# Dk::ABDeploy

[Dk](https://github.com/redding/dk) tasks that implement the A/B deploy scheme.

## Deploy scheme design

Two release dirs, A and B, each have a clone of the app's git repo.  On deploy, whichever release dir is not current is fetched and reset to the deploy commit.  After the source is updated and ready, the current pointer is updated to the new release dir.

This allows for the current running processes to remain running against the previous source while the new source is updated, migrated, built, etc.  Once the new source is ready, the pointer is updated and everything can be restarted.

This has a few advantages over a more tradition single-clone deploy scheme:

* This removes the need to copy the entire source tree after the single common repo has been updated.
* There is no need to calculate release dir names with dates/etc and manage them (ie clean out previous old release dirs)
* This works well with branch deploys as there is no need for any complex rollback logic - just deploy a previous commit to rollback.
* You retain all the benefits of a current pointer that is set to the previous deploy source while the new source is being built/setup.

## Usage

Here is an example "deploy" task that uses dk-abdeploy tasks to compose it's logic:

```ruby
# in config/dk.rb or whatever
require 'dk'
require 'dk-abdeploy'

class MyDeployTask
  incude Dk::Task

  desc "deploy my code"

  ssh_hosts 'my_servers'

  def run!
    # set any required dk-abdeploy params before validating
    set_param(Dk::ABDeploy::ROOT_PARAM_NAME, params['deploy_dir'])
    set_param(Dk::ABDeploy::REPO_PARAM_NAME, params['repo_url'])
    set_param(Dk::ABDeploy::REF_PARAM_NAME,  'origin/master')
    set_param(
      Dk::ABDeploy::PRIMARY_SSH_HOST_PARAM_NAME,
      ssh_hosts('my_servers').first
    )

    # validate the deploy params, config, etc (safe to run on each deploy)
    run_task Dk::ABDeploy::Validate

    # do post-validate custom logic (like maybe setting more friendly param names?)
    set_param('shared_dir',  params[Dk::ABDeploy::SHARED_DIR_PARAM_NAME])
    set_param('current_dir', params[Dk::ABDeploy::CURRENT_DIR_PARAM_NAME])

    # setup the deploy dirs, etc (safe to run on each deploy)
    run_task Dk::ABDeploy::Setup

    # update the source in either the A or B release dir (whichever is not current)
    run_task Dk::ABDeploy::Update

    # do any custom post-source-update logic like:
    # - set more "friendly" param names
    # - bundle
    # - build assets
    # - etc
    set_param('deploy_release_dir', release_dir)

    # symlink the release dir that was just updated as the "current"
    run_task Dk::ABDeploy::Link

    # do any post-symlink logic like (restarting processes, etc)

    # cleanup the deploy
    # (gets the non-updated release dir on the same commit as the updated release dir)
    run_task Dk::ABDeploy::Cleanup
  end

end

Dk.configure do
  task 'deploy', MyDeployTask

  set_param 'repo_url',   'some-repo-rul'
  set_param 'deploy_dir', '/path/to/my/code'

  ssh_hosts 'my_servers', 'myhost1.example.com',
                          'myhost2.example.com'
end
```

then...

```
$ dk -T
deploy     # deploy my code
$ dk deploy
```

## Notes

The scope of the tasks provided here is fairly limited.  This makes no assumptions about your app ie. whether it is Rails or not, whether it is a web app or not, what subdirs it has, etc.  This just covers the basics of setting up the scheme, updating the source and resetting the current pointer.  That's it.

Layer these tasks in your app's specific deploy scheme as callbacks and do all app-specific logic in those tasks.

## Installation

Add this line to your application's Gemfile:

    gem 'dk-abdeploy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dk-abdeploy

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
