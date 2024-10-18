require 'rails_helper'

RSpec.describe Evidence::Ruleset::Latest do
  subject { described_class.new(crime_application, keys) }

  let(:crime_application) do
    instance_double(CrimeApplication, evidence_prompts: [], draft_submission: double)
  end

  before do
    Rails.root.glob('spec/fixtures/files/evidence/rules/*.rb') do |file|
      load file
    end
  end

  describe '#rules' do
    context 'with keys that have definitions' do
      let(:keys) { [:example1, :example2] }

      # NOTE: Although ExampleRule2Budget2025 has the most recent timestamp,
      # it is not loaded because it is archived
      it 'loads the latest Rule version for each key by filename timestamp' do
        expect(subject.rules).to contain_exactly(
          Evidence::Rules::ExampleRule1,
          Evidence::Rules::ExampleRule2Budget2024,
        )
      end
    end

    context 'with keys that do not have definitions' do
      let(:keys) { [:key_not_yet_implemented_with_definition_file] }

      it 'is empty' do
        expect(subject.rules).to be_empty
      end
    end
  end
end
