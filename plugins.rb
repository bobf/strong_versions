require 'strong_versions'

Bundler::Plugin.add_hook('before-install-all') do |dependencies|
  StrongVersions::Dependencies.new(dependencies).validate!
end
