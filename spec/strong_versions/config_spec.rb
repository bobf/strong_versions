# frozen_string_literal: true

RSpec.describe StrongVersions::Config do
  let(:path) { fixture_path('standard') }

  let(:non_existent_path) { '/non/existent/file/i/hope' }

  let(:config) { described_class.new(path) }

  subject { config }

  it { is_expected.to be_a described_class }

  context 'unknown on_failure setting' do
    let(:path) { fixture_path('unknown_on_failure') }

    subject { proc { config } }

    it { is_expected.to raise_error Bundler::BundlerError }
  end

  describe '#exceptions' do
    subject { config.exceptions }

    context 'config exists' do
      it { is_expected.to eql %w[foo bar baz] }
    end

    context 'config exists but no exceptions set' do
      let(:path) { fixture_path('warn_on_failure') }

      it { is_expected.to be_empty }
    end

    context 'config does not exist' do
      let(:path) { non_existent_path }

      it { is_expected.to be_empty }
    end
  end

  describe '#on_failure' do
    subject { config.on_failure }

    context 'config does not exist' do
      let(:path) { non_existent_path }

      it { is_expected.to eql 'raise' }
    end

    context 'config exists: raise' do
      let(:path) { fixture_path('standard') }
    end

    context 'config exists: warn' do
      let(:path) { fixture_path('warn_on_failure') }
    end
  end

  def fixture_path(name)
    File.join(File.expand_path('..', __dir__), 'fixtures', "#{name}.yml")
  end
end
