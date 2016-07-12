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

TODO: Write code samples and usage instructions here

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
