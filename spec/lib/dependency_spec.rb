RSpec.describe StrongVersions::Dependency do
  let(:requirements) { ['~> 1.0'] }
  let(:raw_dependency) do
    double('raw dependency', requirements_list: requirements)
  end

  let(:dependency) { described_class.new(raw_dependency) }

  subject { dependency }

  it { is_expected.to be_a described_class }

  describe '#valid?, #errors' do
    context '(default) valid requirements' do
      let(:requirements) { ['~> 1.0', '~> 0.1'] }
      its(:valid?) { is_expected.to be true }
      its(:errors) { is_expected.to be_empty }
    end

    context '(default) invalid requirements - too specific' do
      let(:requirements) { ['~> 1.0.1'] }
      its(:valid?) { is_expected.to be false }
      its('errors.size') { is_expected.to eql 1 }
    end

    context '(default) invalid requirements - too loose' do
      let(:requirements) { ['~> 1'] }
      its(:valid?) { is_expected.to be false }
      its('errors.size') { is_expected.to eql 1 }
    end

    context '(default) invalid requirements - not pessimistic' do
      let(:requirements) { ['>= 1.0'] }
      its(:valid?) { is_expected.to be false }
      its('errors.size') { is_expected.to eql 1 }
    end

    context '(default) invalid requirements - not pessimistic and too loose' do
      let(:requirements) { ['>= 1'] }
      its(:valid?) { is_expected.to be false }
      its('errors.size') { is_expected.to eql 2 }
    end
  end
end
