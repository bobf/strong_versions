RSpec.describe StrongVersions::Dependencies do
  let(:requirements) { ['~> 1.0'] }
  let(:raw_dependency) do
    double('raw dependency', name: 'test_gem', requirements_list: requirements)
  end

  let(:gem_dependencies) { [raw_dependency] }
  let(:dependencies) { described_class.new(gem_dependencies) }

  subject { dependencies }

  it { is_expected.to be_a described_class }

  describe '#validate' do
    subject { dependencies.validate }

    context 'valid requirements' do
      let(:requirements) { ['~> 1.0'] }
      it { is_expected.to be true }
    end

    context 'invalid requirements' do
      let(:requirements) { ['>= 1.0.1'] }
      it { is_expected.to be false }
    end
  end

  describe '#validate!' do
    subject { proc { dependencies.validate! } }
    context 'valid requirements' do
      let(:requirements) { ['~> 1.0'] }
      it { is_expected.to_not raise_error }
    end

    context 'invalid requirements' do
      let(:requirements) { ['>= 1.0.1'] }
      it do
        is_expected.to raise_error Bundler::GemspecError
      end
    end
  end
end
