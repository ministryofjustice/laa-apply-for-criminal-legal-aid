require 'rails_helper'

RSpec.describe Summary::Components::Saving, type: :component do
  subject(:component) { described_class.new(record:) }

  let(:record) { instance_double(Saving, complete?: true, crime_application: crime_application, **attributes) }

  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }

  let(:attributes) do
    {
      id: 'SAVING123',
      crime_application_id: 'APP123',
      provider_name: 'Bank of Test',
      ownership_type: OwnershipType::APPLICANT,
      sort_code: '01-01-01',
      account_number: '01234500',
      account_balance: '100.01',
      is_overdrawn: YesNoAnswer::NO,
      are_wages_paid_into_account: YesNoAnswer::YES,
      are_partners_wages_paid_into_account: partners_wages,
      saving_type: :bank
    }
  end

  let(:partners_wages) { YesNoAnswer::NO }

  before do
    render_summary_component(component)
  end

  describe 'actions' do
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/capital/add-savings-accounts',
         exact_text: 'Edit Bank account'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) { described_class.new(record: record, show_record_actions: true) }

      describe 'change link' do
        it 'show the correct change link' do
          expect(page).to have_link(
            'Change',
            href: '/applications/APP123/steps/capital/savings/SAVING123',
            exact_text: 'Change Bank account'
          )
        end
      end

      describe 'remove link' do
        it 'show the correct remove link' do
          expect(page).to have_link(
            'Remove',
            href: '/applications/APP123/steps/capital/savings/SAVING123/confirm-destroy',
            exact_text: 'Remove Bank account'
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do # rubocop:disable RSpec/ExampleLength
      expect(page).to have_summary_row(
        'Bank or building society',
        'Bank of Test'
      )
      expect(page).to have_summary_row(
        'Sort code or branch name',
        '01-01-01',
      )
      expect(page).to have_summary_row(
        'Account number',
        '01234500',
      )
      expect(page).to have_summary_row(
        'Account balance',
        '£100.01',
      )
      expect(page).to have_summary_row(
        'Account overdrawn?',
        'No',
      )
      expect(page).to have_summary_row(
        "Client's wages or benefits paid into this account?",
        'Yes',
      )
      expect(page).to have_summary_row(
        'Account holder',
        'Client'
      )
    end

    describe 'the partner wages question' do
      let(:wages_text) { "Partner's wages or benefits paid into this account?" }

      context 'when partner wages question was asked' do
        it 'is shown' do
          expect(page).to have_summary_row(wages_text, 'No')
        end
      end

      context 'when partner wages question was not asked' do
        let(:partners_wages) { nil }

        it 'is not shown' do
          expect(page).not_to have_content(wages_text)
        end
      end
    end

    context 'when answers are missing' do
      let(:attributes) do
        {
          id: 'SAVING123',
          crime_application_id: 'APP123',
          provider_name: nil,
          ownership_type: nil,
          sort_code: nil,
          account_number: nil,
          account_balance: nil,
          is_overdrawn: nil,
          are_wages_paid_into_account: nil,
          are_partners_wages_paid_into_account: nil,
          saving_type: :bank
        }
      end

      it 'renders as summary list with the correct absence_answer' do
        expect(page).to have_summary_row('Bank or building society', '')
        expect(page).to have_summary_row('Sort code or branch name', '')
        expect(page).to have_summary_row('Account number', '')
        expect(page).to have_summary_row('Account balance', '')
        expect(page).to have_summary_row('Account overdrawn?', '')
        expect(page).to have_summary_row("Client's wages or benefits paid into this account?", '')
        expect(page).to have_summary_row('Account holder', '')
      end
    end
  end

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    let(:attributes) { super().merge({ saving_type: }) }

    context 'when bank' do
      let(:saving_type) { :bank }

      it { is_expected.to eq 'Bank account' }
    end

    context 'when building society' do
      let(:saving_type) { :building_society }

      it { is_expected.to eq 'Building society account' }
    end

    context 'when Cash ISA' do
      let(:saving_type) { :cash_isa }

      it { is_expected.to eq 'Cash ISA' }
    end

    context 'when National savings or PO' do
      let(:saving_type) { :national_savings_or_post_office }

      it { is_expected.to eq 'National Savings or Post Office account' }
    end

    context 'when other' do
      let(:saving_type) { :other }

      it { is_expected.to eq 'Other cash investment' }
    end
  end
end
