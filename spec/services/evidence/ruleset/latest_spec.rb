require 'rails_helper'

RSpec.describe Evidence::Ruleset::Latest do
  let(:crime_application) do
    instance_double(CrimeApplication, evidence_prompts: [], draft_submission: double)
  end

  before do
    Rails.root.glob('spec/fixtures/files/evidence/rules/*.rb') do |file|
      load file
    end
  end

  describe '#rules' do
    subject { described_class.new(crime_application, [:example1, :example2]) }

    # NOTE: Although ExampleRule2Budget2025 has the most recent timestamp,
    # it is not loaded because it is archived
    it 'loads the latest Rule version for each key by filename timestamp' do
      expect(subject.rules).to contain_exactly(
        Evidence::Rules::ExampleRule1,
        Evidence::Rules::ExampleRule2Budget2024,
      )
    end
  end
end
