require 'rails_helper'

describe Summary::Components::FundingDecision, type: :component do
  subject(:component) { render_summary_component(described_class.new(record: record, show_actions: false)) }

  let(:record) { instance_double(LaaCrimeSchemas::Structs::Decision, **attributes) }
  let(:crime_application) { instance_double(CrimeApplication, id: '445') }

  let(:attributes) do
    {
      case_id: 'APP123',
      maat_id: 'M123',
      interests_of_justice: interests_of_justice,
      means: means,
      funding_decision: funding_decision,
      court_type: 'crown',
      comment: 'Decision comment'
    }
  end

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
      result: means_result,
      details: 'Means details',
      assessed_by: 'Grace Nolan',
      assessed_on: Date.new(2024, 10, 9),
    )
  end

  let(:funding_decision) { 'refused' }
  let(:means_result) { 'failed' }

  before { component }

  describe 'answers' do
    it 'renders as summary list' do
      expect(summary_card('Case')).to have_rows(
        'MAAT ID', 'M123',
        'Case number', 'APP123',
        'Means test', 'Crown Court',
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

  context 'when funding decision is "granted" and means "passed"' do
    let(:funding_decision) { 'granted' }
    let(:means_result) { 'passed' }

    it { is_expected.to have_text('Granted') }
  end

  context 'when funding decision is "granted" and means "passed_with_contribution"' do
    let(:funding_decision) { 'granted' }
    let(:means_result) { 'passed_with_contribution' }

    it { is_expected.to have_text('Granted - with a contribution') }
  end

  context 'when funding decision is "granted" and means "failed"' do
    let(:funding_decision) { 'granted' }

    it { is_expected.to have_text('Granted - failed means test') }
  end
end
