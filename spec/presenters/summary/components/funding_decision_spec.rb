require 'rails_helper'

describe Summary::Components::FundingDecision, type: :component do
  subject(:component) { render_summary_component(described_class.new(record: record, show_actions: false)) }

  let(:record) { instance_double(LaaCrimeSchemas::Structs::Decision, **attributes) }
  let(:crime_application) { instance_double(CrimeApplication, id: '445') }

  let(:attributes) do
    {
      case_id:,
      maat_id:,
      interests_of_justice:,
      means:,
      funding_decision:,
      comment:
    }
  end

  let(:case_id) { 'APP123' }
  let(:maat_id) { 'M123' }
  let(:interests_of_justice) do
    instance_double(
      LaaCrimeSchemas::Structs::TestResult,
      result: 'failed',
      details: 'IoJ details',
      assessed_by: 'Grace Nolan',
      assessed_on: Date.new(2024, 10, 8),
    )
  end
  let(:means) do
    instance_double(
      LaaCrimeSchemas::Structs::TestResult,
      result: 'failed',
      details: 'Means details',
      assessed_by: 'Grace Nolan',
      assessed_on: Date.new(2024, 10, 9),
    )
  end
  let(:funding_decision) { 'refused' }
  let(:comment) { 'Decision comment' }

  before { component }

  describe 'answers' do
    it 'renders as summary list' do
      expect(summary_card('Case')).to have_rows(
        'MAAT ID', 'M123',
        'Case number', 'APP123',
        'Interests of justice (IoJ) test result', 'Failed',
        'IoJ comment', 'IoJ details',
        'IoJ caseworker', 'Grace Nolan',
        'IoJ test date', '8 October 2024',
        'Means test result', 'Failed',
        'Means test caseworker', 'Grace Nolan',
        'Means test date', '9 October 2024',
        'Overall result', 'Refused',
        'Further information about the decision', 'Decision comment'
      )
    end
  end
end
