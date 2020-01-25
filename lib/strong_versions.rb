# frozen_string_literal: true

require 'yaml'

require 'i18n'
require 'paint'

require 'strong_versions/config'
require 'strong_versions/dependency'
require 'strong_versions/dependency_finder'
require 'strong_versions/dependencies'
require 'strong_versions/errors'
require 'strong_versions/suggestion'
require 'strong_versions/terminal'
require 'strong_versions/version'

module StrongVersions
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end

I18n.config.available_locales = :en
I18n.load_path += Dir[
  StrongVersions.root.join('config', 'locales', '**', '*.yml')
]
