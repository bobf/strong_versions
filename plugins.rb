# frozen_string_literal: true

require 'strong_versions'

Bundler::Plugin.add_hook('before-install-all') do |dependencies|
  config_path = Bundler.root.join('.strong_versions.yml')
  config = StrongVersions::Config.new(config_path)

  StrongVersions::Dependencies.new(dependencies).validate!(
    except: config.exceptions,
    on_failure: config.on_failure
  )
end
