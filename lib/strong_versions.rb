# frozen_string_literal: true

require 'i18n'

require 'strong_versions/version'
require 'strong_versions/dependency'
require 'strong_versions/dependencies'

I18n.config.available_locales = :en
I18n.load_path += Dir[
  File.join(File.expand_path('..', __dir__), 'config', 'locales', '**', '*.yml')
]

module StrongVersions
end
