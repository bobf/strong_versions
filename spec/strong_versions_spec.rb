# frozen_string_literal: true

RSpec.describe StrongVersions do
  it 'has a version number' do
    expect(StrongVersions::VERSION).not_to be nil
  end
end
