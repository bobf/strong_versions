# frozen_string_literal: true

module StrongVersions
  module Regexes
    class << self
      def gemfile(name)
        /^(\s*)gem\s+['"]#{name}['"].*$/
      end

      def gemspec(name)
        /^(\s*[A-Za-z]+\.)add_[a-z_]*_?dependency\s*\(?\s*['"]#{name}['"].*$/
      end
    end
  end
end
