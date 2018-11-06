# frozen_string_literal: true

module StrongVersions
  class GemfileDSL
    attr_reader :_strong_versions__installed

    def initialize
      @_strong_versions__installed = false
    end

    def plugin(name, *_args)
      @_strong_versions__installed = true if name == 'strong_versions'
    end

    # If we don't explicitly define this method then RubyGems' Kernel#gem is
    # called instead.
    def gem(*_args); end

    private

    # rubocop:disable Style/MethodMissingSuper
    def method_missing(_method, *_args, &_block); end
    # rubocop:enable Style/MethodMissingSuper

    def respond_to_missing?(_method)
      true
    end
  end
end
