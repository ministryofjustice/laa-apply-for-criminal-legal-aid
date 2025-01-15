require 'rails_helper'

RSpec.describe Summary::Components::Investment, type: :component do
  subject(:component) { render_summary_component(described_class.new(record:)) }

  let(:record) { instance_double(Investment, complete?: true, crime_application: crime_application, **attributes) }

  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }

  let(:attributes) do
    {
      id: 'investment123',
      crime_application_id: 'APP123',
      description: 'About the shares',
      investment_type: 'share',
      value: 100,
      ownership_type: 'applicant'
    }
  end

  before { component }

  describe 'actions' do
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/capital/add-investments',
          exact_text: 'Edit Shares'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) { render_summary_component(described_class.new(record: record, show_record_actions: true)) }

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
            href: '/applications/APP123/steps/capital/investments/investment123/confirm-destroy',
            exact_text: 'Remove Shares'
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do
      expect(page).to have_summary_row(
        'Investment description',
        'About the shares'
      )
      expect(page).to have_summary_row(
        'Value',
        '£100.00'
      )
      expect(page).to have_summary_row(
        'Name the investment is in',
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
          ownership_type: nil
        }
      end

      it 'renders as summary list with the correct absence_answer' do
        expect(page).to have_summary_row(
          'Investment description',
          ''
        )
        expect(page).to have_summary_row(
          'Value',
          ''
        )
        expect(page).to have_summary_row(
          'Name the investment is in',
          ''
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

      it { is_expected.to eq 'Stocks, including gilts and government bonds' }
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
