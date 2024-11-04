require 'rails_helper'

describe Summary::Components::FundingDecision, type: :component do
  subject(:component) { render_summary_component(described_class.new(record: record, show_actions: false)) }

  let(:record) { instance_double(LaaCrimeSchemas::Structs::Decision, **attributes) }
  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }

  let(:attributes) do
    {
      reference:,
      maat_id:,
      interests_of_justice:,
      means:,
      funding_decision:,
      comment:
    }
  end

  let(:reference) { 'APP123' }
  let(:maat_id) { 'M123' }
  let(:interests_of_justice) do
    instance_double(
      LaaCrimeSchemas::Structs::TestResult,
      result: 'pass',
      details: 'IoJ details',
      assessed_by: 'Grace Nolan',
      assessed_on: Date.new(2024, 10, 8),
    )
  end
  let(:means) do
    instance_double(
      LaaCrimeSchemas::Structs::TestResult,
      result: 'fail',
      details: 'Means details',
      assessed_by: 'Grace Nolan',
      assessed_on: Date.new(2024, 10, 9),
    )
  end
  let(:funding_decision) { 'granted_on_ioj' }
  let(:comment) { 'Decision comment' }

  before { component }

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    it { is_expected.to eq('Case') }
  end

  describe 'answers' do
    it 'renders as summary list' do # rubocop:disable RSpec/MultipleExpectations
      expect(page).to have_summary_row('MAAT ID', 'M123')
      expect(page).to have_summary_row('Case number', 'APP123')
      expect(page).to have_summary_row('Interests of justice test result', 'Passed')
      expect(page).to have_summary_row('Interests of justice reason', 'IoJ details')
      expect(page).to have_summary_row('Interests of justice test caseworker name', 'Grace Nolan')
      expect(page).to have_summary_row('Date of interests of justice test', '8 October 2024')
      expect(page).to have_summary_row('Means test result', 'Failed')
      expect(page).to have_summary_row('Means test caseworker name', 'Grace Nolan')
      expect(page).to have_summary_row('Date of means test', '9 October 2024')
      expect(page).to have_summary_row('Overall result', 'Granted')
      expect(page).to have_summary_row('Further information about the decision', 'Decision comment')
    end
  end
end
