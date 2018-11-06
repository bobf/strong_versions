# frozen_string_literal: true

RSpec.describe StrongVersions::GemfileDSL do
  subject(:gemfile_dsl) { described_class.new }

  # These are all the DSL methods defined by `Bundler::Dsl`. We include them
  # here more as a reference than anything.
  its(:source) { is_expected.to be_nil }
  its(:gem) { is_expected.to be_nil }
  its(:gemspec) { is_expected.to be_nil }
  its(:git) { is_expected.to be_nil }
  its(:github) { is_expected.to be_nil }
  its(:git_source) { is_expected.to be_nil }
  its(:path) { is_expected.to be_nil }
  its(:group) { is_expected.to be_nil }
  its(:env) { is_expected.to be_nil }
  its(:install_if) { is_expected.to be_nil }

  describe '#_strong_versions__installed' do
    subject { gemfile_dsl._strong_versions__installed }
    context '`plugin` called with "strong_versions"' do
      before { gemfile_dsl.plugin('strong_versions', '1.0.0') }
      it { is_expected.to be true }
    end

    context '`plugin` called without "strong_versions"' do
      before { gemfile_dsl.plugin('other_plugin', '1.0.0') }
      it { is_expected.to be false }
    end

    context '`plugin` never called' do
      it { is_expected.to be false }
    end
  end
end
