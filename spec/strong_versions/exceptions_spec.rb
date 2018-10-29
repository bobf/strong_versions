# frozen_string_literal: true

RSpec.describe StrongVersions::Exceptions do
  let(:exceptions) { described_class.new }

  subject { exceptions }

  it { is_expected.to be_a described_class }

  describe '.find_all' do
    subject { described_class.find_all(path) }

    context 'config exists' do
      let(:path) do
        File.join(File.expand_path('..', __dir__), 'fixtures', 'config')
      end

      it { is_expected.to eql %w[foo bar baz] }
    end

    context 'config does not exist' do
      let(:path) { '/non/existent/file/i/hope' }

      it { is_expected.to be_empty }
    end
  end
end
