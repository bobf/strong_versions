# frozen_string_literal: true

RSpec.describe StrongVersions::InstallDetector do
  let(:gemfile_path) { fixture('Gemfile.installed') }
  subject(:install_detector) { described_class.new([gemfile_path]) }

  it { is_expected.to be_a described_class }

  describe '#installed?' do
    subject(:installed?) { install_detector.installed? }

    context 'installed' do
      let(:gemfile_path) { fixture('Gemfile.installed') }
      it { is_expected.to be true }
    end

    context 'not installed' do
      let(:gemfile_path) { fixture('Gemfile.not_installed') }
      it { is_expected.to be false }
    end
  end

  def fixture(name)
    StrongVersions.root.join('spec', 'fixtures', name)
  end
end
