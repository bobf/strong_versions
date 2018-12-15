# frozen_string_literal: true

require 'yaml'

begin
  require 'i18n'
  I18n.config.available_locales = :en
  I18n.load_path += Dir[
    File.join(
      File.expand_path('..', __dir__), 'config', 'locales', '**', '*.yml'
    )
  ]
rescue LoadError
  require 'strong_versions/i18n_stub'
end

require 'strong_versions/config'
require 'strong_versions/dependency'
require 'strong_versions/dependency_finder'
require 'strong_versions/dependencies'
require 'strong_versions/suggestion'
require 'strong_versions/terminal'
require 'strong_versions/version'

module StrongVersions
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end
