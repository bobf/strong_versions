# frozen_string_literal: true

RSpec.describe StrongVersions::Dependencies do
  let(:requirements) { ['~> 1.0'] }
  let(:raw_dependency) do
    double(
      'raw dependency',
      name: 'test_gem',
      requirements_list: requirements,
      source: nil
    )
  end

  let(:gem_dependencies) { [raw_dependency] }
  let(:dependencies) { described_class.new(gem_dependencies) }

  subject { dependencies }

  it { is_expected.to be_a described_class }

  describe '#validate' do
    let(:options) { {} }

    subject { dependencies.validate(options) }

    context 'valid requirements' do
      let(:requirements) { ['~> 1.0'] }
      it { is_expected.to be true }
    end

    context 'invalid requirements' do
      let(:requirements) { ['>= 1.0.1'] }
      it { is_expected.to be false }
    end

    context 'excepted requirements' do
      let(:options) { { except: 'skip_gem' } }
      let(:raw_dependency) do
        double(
          'raw dependency',
          name: 'skip_gem',
          requirements_list: ['>= 1'],
          source: nil
        )
      end

      it { is_expected.to be true }
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
      it { is_expected.to raise_error Bundler::GemspecError }
    end
  end
end
