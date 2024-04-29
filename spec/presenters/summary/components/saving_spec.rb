require 'rails_helper'

RSpec.describe Summary::Components::Saving, type: :component do
  subject(:component) { render_inline(described_class.new(record:)) }

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
      saving_type: :bank
    }
  end

  before { component }

  describe 'actions' do
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/capital/add_savings_accounts',
         exact_text: 'Edit Bank account'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) { render_inline(described_class.new(record: record, show_record_actions: true)) }

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
            href: '/applications/APP123/steps/capital/savings/SAVING123/confirm_destroy',
            exact_text: 'Remove Bank account'
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do # rubocop:disable RSpec/ExampleLength
      expect(page).to have_summary_row(
        'What is the name of the bank, building society or other holder of the savings?',
        'Bank of Test'
      )
      expect(page).to have_summary_row(
        'What is the sort code or branch name?',
        '01-01-01',
      )
      expect(page).to have_summary_row(
        'What is the account number?',
        '01234500',
      )
      expect(page).to have_summary_row(
        'What is the account balance?',
        '£100.01',
      )
      expect(page).to have_summary_row(
        'Is the account overdrawn?',
        'No',
      )
      expect(page).to have_summary_row(
        'Are your client’s wages or benefits paid into this account?',
        'Yes',
      )
      expect(page).to have_summary_row(
        'Whose name is the account in?',
        'Client'
      )
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
          saving_type: :bank
        }
      end

      it 'renders as summary list with the correct absence_answer' do # rubocop:disable RSpec/ExampleLength
        expect(page).to have_summary_row(
          'What is the name of the bank, building society or other holder of the savings?',
          ''
        )
        expect(page).to have_summary_row(
          'What is the sort code or branch name?',
          '',
        )
        expect(page).to have_summary_row(
          'What is the account number?',
          '',
        )
        expect(page).to have_summary_row(
          'What is the account balance?',
          '',
        )
        expect(page).to have_summary_row(
          'Is the account overdrawn?',
          '',
        )
        expect(page).to have_summary_row(
          'Are your client’s wages or benefits paid into this account?',
          '',
        )
        expect(page).to have_summary_row(
          'Whose name is the account in?',
          '',
        )
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

    context 'when National sacings or PO' do
      let(:saving_type) { :national_savings_or_post_office }

      it { is_expected.to eq 'National Savings or Post Office account' }
    end

    context 'when other' do
      let(:saving_type) { :other }

      it { is_expected.to eq 'Other cash investment' }
    end
  end
end
