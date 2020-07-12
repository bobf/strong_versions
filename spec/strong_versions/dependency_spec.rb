# frozen_string_literal: true

RSpec.describe StrongVersions::Dependency do
  subject { dependency }

  let(:requirements) { ['~> 1.0'] }
  let(:raw_dependency) do
    double(
      'raw dependency',
      name: 'test_gem',
      requirements_list: requirements,
      source: nil,
      gemfile: Pathname.new('/path/to/gemfile')
    )
  end

  let(:dependency) { described_class.new(raw_dependency, lockfile) }
  its(:gemfile) { is_expected.to eql raw_dependency.gemfile }
  let(:lockfile) { nil }

  it { is_expected.to be_a described_class }
  its(:name) { is_expected.to eql 'test_gem' }

  describe '#suggested_definition' do
    subject(:suggested_definition) { dependency.suggested_definition(type) }

    let(:lockfile) { instance_double(Bundler::LockfileParser) }
    let(:spec) { instance_double(Bundler::LazySpecification) }
    let(:gem) { double(type: :runtime, name: 'test_gem') }
    let(:gemspec) do
      double(loaded_from: '/somewhere', dependencies: [gem])
    end

    before do
      allow(lockfile).to receive(:specs) { [spec] }
      allow(spec).to receive(:name) { 'test_gem' }
      allow(spec).to receive(:version) { '1.0.9' }
      allow(Bundler).to receive(:load_gemspec) { gemspec }
    end

    context 'gemfile' do
      let(:type) { :gemfile }
      it { is_expected.to eql "gem 'test_gem', '~> 1.0'" }
    end

    context 'gemspec' do
      let(:type) { :gemspec }
      let(:expected) { "add_runtime_dependency 'test_gem', '~> 1.0'" }
      it { is_expected.to eql expected }
    end
  end

  shared_examples 'valid requirements' do
    its(:valid?) { is_expected.to be true }
    its(:errors) { is_expected.to be_empty }
    its(:updatable?) { is_expected.to be false }
  end

  shared_examples 'invalid requirements' do |errors:|
    its(:valid?) { is_expected.to be false }
    its('errors.size') { is_expected.to eql errors }
  end

  describe '#suggested_version' do
    subject(:suggested_version) { dependency.suggested_version.suggestion.to_s }
    let(:lockfile) { instance_double(Bundler::LockfileParser) }
    let(:spec) { instance_double(Bundler::LazySpecification) }

    before do
      allow(lockfile).to receive(:specs) { [spec] }
      allow(spec).to receive(:name) { 'test_gem' }
      allow(spec).to receive(:version) { '1.4.8' }
    end

    it { is_expected.to eql "'~> 1.4'" }
  end

  describe '#valid?, #errors' do
    context 'valid' do
      context 'major and minor version' do
        let(:requirements) { ['~> 1.0', '~> 2.50'] }
        it_behaves_like 'valid requirements'
      end

      context 'pessimistic with upper limit (<)' do
        let(:requirements) { ['~> 1.5', '< 1.7.3'] }
        it_behaves_like 'valid requirements'
      end

      context 'pessimistic with upper limit (<=)' do
        let(:requirements) { ['~> 1.5', '<= 1.7'] }
        it_behaves_like 'valid requirements'
      end

      context 'sub-1.0' do
        let(:requirements) { ['~> 0.5.1'] }
        it_behaves_like 'valid requirements'
      end

      context 'double-digit major version' do
        let(:requirements) { ['~> 10.0'] }
        it_behaves_like 'valid requirements'
      end

      context 'source is git' do
        let(:raw_dependency) do
          double(
            'raw dependency',
            name: 'test_gem',
            requirements_list: ['1'],
            source: Bundler::Source::Git.new('git://git.example.com/repo.git')
          )
        end

        it_behaves_like 'valid requirements'
      end
      context 'source is a path' do
        let(:raw_dependency) do
          double(
            'raw dependency',
            name: 'test_gem',
            requirements_list: ['1.3.0'],
            source: Bundler::Source::Path.new('/foo/bar')
          )
        end

        it_behaves_like 'valid requirements'
      end
    end

    context 'invalid' do
      context 'sub-1.0 with > operator' do
        let(:requirements) { ['> 0.5.1'] }
        it_behaves_like 'invalid requirements', errors: 1
      end

      context 'sub-1.0 with >= operator' do
        let(:requirements) { ['>= 0.5.1'] }
        it_behaves_like 'invalid requirements', errors: 1
      end

      context 'too specific' do
        let(:requirements) { ['~> 1.0.1'] }
        it_behaves_like 'invalid requirements', errors: 1
      end

      context 'too loose, >= 1' do
        let(:requirements) { ['~> 1'] }
        it_behaves_like 'invalid requirements', errors: 1
      end

      context 'too loose, < 1' do
        let(:requirements) { ['~> 0.9'] }
        it_behaves_like 'invalid requirements', errors: 1
      end

      context 'not pessimistic' do
        let(:requirements) { ['>= 1.0'] }
        it_behaves_like 'invalid requirements', errors: 1
      end

      context 'not pessimistic and too loose' do
        let(:requirements) { ['>= 1'] }
        it_behaves_like 'invalid requirements', errors: 2
      end
    end
  end
end
