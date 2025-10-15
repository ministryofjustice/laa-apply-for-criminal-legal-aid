require 'rails_helper'

RSpec.describe 'Savings summary page', :authorized do
  include_context 'with office code selected'

  before do
    allow(MeansStatus).to receive(:full_capital_required?).and_return('true')

    app = CrimeApplication.create(
      capital: Capital.new,
      office_code: selected_office_code
    )
    app.savings.create!(saving_type: SavingType::BANK,
                        provider_name: 'Bank of Test',
                        ownership_type: OwnershipType::APPLICANT,
                        sort_code: '01-01-01',
                        account_number: '01234500',
                        account_balance: '100.01',
                        is_overdrawn: YesNoAnswer.values.sample,
                        are_wages_paid_into_account: YesNoAnswer.values.sample)
  end

  describe 'list of added savings in summary page' do
    let(:crime_application) { CrimeApplication.first }

    before do
      get edit_steps_capital_savings_summary_path(crime_application)
    end

    it 'lists the offences with their details and action links' do
      expect(response).to have_http_status(:success)
      # summary card details tested in the Summary::Components::Saving spec
      assert_select '.govuk-summary-card'
      assert_select 'h1', 'You have added 1 saving'

      # confirm action are shown
      assert_select 'li.govuk-summary-card__action', count: 2
    end
  end

  describe 'delete a saving' do
    let(:crime_application) { CrimeApplication.first }
    let(:saving) { Saving.first }

    before do
      get confirm_destroy_steps_capital_savings_path(id: crime_application, saving_id: saving)
    end

    it 'allows a user to confirm before deleting a saving' do
      # summary card details tested in the Summary::Components::Saving spec
      assert_select '.govuk-summary-card'
      # confirm action are not shown
      assert_select 'li.govuk-summary-card__action', count: 0

      expect(response.body).to include('Are you sure you want to remove this savings account?')
      expect(response.body).to include('Yes, remove it')
      expect(response.body).to include('No, do not remove it')
    end

    context 'when there are other savings' do
      it 'deletes the saving and redirects back to the summary page' do
        # ensure we have at least an additional saving
        saving = crime_application.savings.create!(
          saving_type: SavingType::CASH_ISA,
          ownership_type: 'applicant'
        )

        expect do
          delete steps_capital_savings_path(id: crime_application, saving_id: saving)
        end.to change(Saving, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_capital_savings_summary_path(crime_application))

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the savings account'
        end
      end
    end

    context 'when there are no more savings' do
      it 'deletes the saving and redirects to the saving type page' do
        expect do
          delete steps_capital_savings_path(id: crime_application, saving_id: saving)
        end.to change(Saving, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_capital_saving_type_path)

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the savings account'
        end
      end
    end
  end
end
