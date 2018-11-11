# frozen_string_literal: true

# XXX: StrongVersions was intended to be a Bundler plugin but, unfortunately,
# the plugin system is still in its infancy and has many issues which make it
# not fit for purpose. If those issues get resolved then I will re-add
# documentation for use as a plugin.

require 'strong_versions'

Bundler::Plugin.add_hook('before-install-all') do |dependencies|
  # `StrongVersions.installed?` checks to see if 'strong_versions' is a
  # dependency (i.e. included in the `Gemfile`). The reason for this is that,
  # once a plugin has been installed, removing it from the `Gemfile` does not
  # remove the plugin or its hooks so the hook will still run on every
  # `bundle install`. I think that is not what a user would expect so we check
  # that the plugin is explicitly referenced in the `Gemfile`.
  run_hook(dependencies) if StrongVersions.installed?
end

def run_hook(dependencies)
  config_path = Bundler.root.join('.strong_versions.yml')
  config = StrongVersions::Config.new(config_path)

  StrongVersions::Dependencies.new(dependencies).validate!(
    except: config.exceptions,
    on_failure: config.on_failure
  )
end
