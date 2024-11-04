require 'rails_helper'

RSpec.describe Evidence::Ruleset::Hydrated do
  let(:crime_application) do
    instance_double(CrimeApplication, evidence_prompts:)
  end

  before do
    Rails.root.glob('spec/fixtures/files/evidence/rules/*.rb') do |file|
      load file
    end
  end

  describe '#rules' do
    # NOTE: After a prompt is generated and persisted for the first
    # time, the ruleset will be 'Latest' as that was the ruleset executed.
    # When the Hyrdated ruleset is executed the prompt will be re-saved with
    # ruleset: 'Hyrdrated'
    let(:evidence_prompts) do
      [
        {
          'id' => 'ExampleRule2',
          'key' => 'example2',
          'run' => {
            'other' => {
              'prompt' => [''],
              'result' => false
            },
            'client' => {
              'prompt' => ['this is the original prompt'],
              'result' => true
            },
            'partner' => {
              'prompt' => [],
              'result' => false
            }
          },
          'group' => 'outgoings',
          'ruleset' => 'Latest'
        },
        {
          'id' => 'NonExistentRuleClass',
          'key' => 'accidentally_deleted',
          'run' => {
            'other' => {
              'prompt' => [],
              'result' => false
            },
            'client' => {
              'prompt' => [],
              'result' => false
            },
            'partner' => {
              'prompt' => [],
              'result' => false
            }
          },
          'group' => 'none',
          'ruleset' => 'Latest'
        },
      ]
    end

    it 'loads Rule definitions based on persisted evidence_prompts' do
      hydrated_ruleset = described_class.new(crime_application, [:example2, :accidentally_deleted])

      expect(hydrated_ruleset.rules).to contain_exactly(Evidence::Rules::ExampleRule2)
      expect(Evidence::Rules::ExampleRule2.archived).to be true
    end

    it 'logs error when implemented Rule cannot be loaded' do
      expect(Rails.logger).to receive(:warn).with(
        /Rule definition NonExistentRuleClass not found - has it been deleted?/
      )

      expect(Rails.logger).to receive(:error).with(
        /Key accidentally_deleted does not have a Rule definition - generate one/
      )

      rules = described_class.new(crime_application, [:example2, :accidentally_deleted]).rules
      expect(rules).to contain_exactly(Evidence::Rules::ExampleRule2)
    end

    context 'with keys that do not have definitions' do
      it 'is empty' do
        rules = described_class.new(crime_application, [:key_not_yet_implemented_with_definition_file]).rules

        expect(rules).to be_empty
      end
    end
  end
end
