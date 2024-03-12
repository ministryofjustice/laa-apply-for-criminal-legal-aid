require 'rails_helper'

RSpec.describe Summary::Components::Investment, type: :component do
  subject(:component) { render_inline(described_class.new(record:)) }

  let(:record) { instance_double(Investment, complete?: true, crime_application: crime_application, **attributes) }

  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }

  let(:attributes) do
    {
      id: 'investment123',
      crime_application_id: 'APP123',
      description: 'About the shares',
      investment_type: 'share',
      value: 100,
      holder: 'applicant'
    }
  end

  before { component }

  describe 'actions' do
    describe 'change link' do
      it 'show the correct change link' do
        expect(page).to have_link(
          'Change',
          href: '/applications/APP123/steps/capital/investments/investment123',
          exact_text: 'Change Shares'
        )
      end
    end

    describe 'remove link' do
      it 'show the correct remove link' do
        expect(page).to have_link(
          'Remove',
          href: '/applications/APP123/steps/capital/investments/investment123/confirm_destroy',
          exact_text: 'Remove Shares'
        )
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do
      expect(page).to have_summary_row(
        'Describe the investment',
        'About the shares'
      )
      expect(page).to have_summary_row(
        'What is the value of the investment?',
        '£100.00'
      )
      expect(page).to have_summary_row(
        'Whose name is the investment in?',
        'Client'
      )
    end

    context 'when answers are missing' do
      let(:attributes) do
        {
          id: 'investment123',
          crime_application_id: 'APP123',
          description: nil,
          investment_type: nil,
          value: nil,
          holder: nil
        }
      end

      it 'renders as summary list with the correct absence_answer' do
        expect(page).to have_summary_row(
          'Describe the investment',
          'None'
        )
        expect(page).to have_summary_row(
          'What is the value of the investment?',
          'None'
        )
        expect(page).to have_summary_row(
          'Whose name is the investment in?',
          'None'
        )
      end
    end
  end

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    let(:attributes) { super().merge({ investment_type: }) }

    context 'when bond' do
      let(:investment_type) { :bond }

      it { is_expected.to eq 'Investment bond' }
    end

    context 'when PEP' do
      let(:investment_type) { :pep }

      it { is_expected.to eq 'Personal equity plan (PEP)' }
    end

    context 'when Shares' do
      let(:investment_type) { :share }

      it { is_expected.to eq 'Shares' }
    end

    context 'when Stocks' do
      let(:investment_type) { :stock }

      it { is_expected.to eq 'Stock, including gilts and government bonds' }
    end

    context 'when Share ISA' do
      let(:investment_type) { :share_isa }

      it { is_expected.to eq 'Share ISA' }
    end

    context 'when Unit trust' do
      let(:investment_type) { :unit_trust }

      it { is_expected.to eq 'Unit trust' }
    end

    context 'when other' do
      let(:investment_type) { :other }

      it { is_expected.to eq 'Other lump sum investment' }
    end
  end
end
