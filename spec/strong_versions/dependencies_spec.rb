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
  let(:options) { { except: [] } }

  subject { dependencies }

  it { is_expected.to be_a described_class }

  describe '#validate' do
    subject(:validate) { dependencies.validate(options) }

    context 'valid requirements' do
      let(:requirements) { ['~> 1.0'] }
      it { is_expected.to be true }
    end

    context 'invalid requirements' do
      let(:requirements) { ['>= 1.0.1'] }
      it { is_expected.to be false }
    end

    context 'excepted requirements' do
      let(:options) { { except: ['skip_gem'] } }
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

    context 'auto-correct' do
      let(:options) { { auto_correct: true } }
      it 'raises an error' do
        expect { validate }
          .to raise_error(StrongVersions::UnsafeAutoCorrectError)
      end
    end
  end

  describe '#validate!' do
    subject { proc { dependencies.validate!(options) } }
    context 'valid requirements' do
      let(:requirements) { ['~> 1.0'] }
      it { is_expected.to_not raise_error }
    end

    context 'invalid requirements' do
      let(:requirements) { ['>= 1.0.1'] }
      it { is_expected.to raise_error Bundler::GemspecError }
    end

    context 'auto-correct' do
      let(:raw_dependency) do
        double(
          name: 'test_gem',
          requirements_list: requirements,
          gemfile: Pathname.new(Tempfile.new.path),
          source: nil
        )
      end
      let(:requirements) { ['~> 1'] }
      let(:options) { { auto_correct: true } }
      let(:gemfile) { raw_dependency.gemfile }
      let(:lockfile) { StrongVersions.root.join('spec/fixtures/Gemfile.lock') }
      let(:fixture) do
        StrongVersions.root.join('spec/fixtures/Gemfile.example')
      end

      before { File.write(gemfile, File.read(fixture)) }
      before { allow(Bundler).to receive(:default_lockfile) { lockfile.to_s } }

      it 'auto-corrects gemfile' do
        expect(File.read(gemfile)).to_not include "gem 'test_gem', '~> 1.3'"
        dependencies.validate!(options)
        expect(File.read(gemfile)).to include "gem 'test_gem', '~> 1.3'"
      end

      context 'with necessary guard definition' do
        let(:requirements) { ['~> 1', '>= 1.4'] }

        it 'leaves necessary guard definition intact' do
          dependencies.validate!(options)
          expect(File.read(gemfile)).to include "'~> 1.3', '>= 1.4'"
        end
      end
    end
  end
end
