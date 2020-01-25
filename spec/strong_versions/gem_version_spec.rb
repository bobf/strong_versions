# frozen_string_literal: true

RSpec.describe StrongVersions::GemVersion do
  subject(:gem_version) { described_class.new(version) }

  let(:version) { '' }

  it { is_expected.to be_a described_class }

  describe '#version' do
    subject(:version) { gem_version.version }
    let(:version) { '0.2.1' }
    it { is_expected.to eql '0.2.1' }
  end

  describe '#missing?' do
    subject(:missing) { gem_version.missing? }

    context 'valid version' do
      let(:version) { '1.2.3' }
      it { is_expected.to be false }
    end

    context 'invalid version' do
      let(:version) { 'a.b.c' }
      it { is_expected.to be true }
    end
  end

  describe '#version_string' do
    subject { gem_version.suggestion }

    context 'stable release' do
      let(:version) { '1.4.8' }
      it { is_expected.to eql "'~> 1.4'" }
    end

    context 'unstable release' do
      let(:version) { '0.2.1' }
      it { is_expected.to eql "'~> 0.2.1'" }
    end

    context 'non-standard release' do
      let(:version) { '1.9.beta4' }
      it { is_expected.to eql '' }
    end

    context 'garbage' do
      let(:version) { 'a.b.c' }
      it { is_expected.to eql '' }
    end
  end
end
