require 'rails_helper'

RSpec.describe 'Investments summary page', :authorized do
  include_context 'with office code selected'

  before do
    allow(MeansStatus).to receive(:full_capital_required?).and_return('true')

    app = CrimeApplication.create(capital: Capital.new, office_code: selected_office_code)
    app.investments.create!(investment_type: InvestmentType::BOND,
                            description: 'About the Bond',
                            value: 10_001,
                            ownership_type: OwnershipType::APPLICANT)
  end

  describe 'list of added investments in summary page' do
    let(:crime_application) { CrimeApplication.first }

    before do
      get edit_steps_capital_investments_summary_path(crime_application)
    end

    it 'lists the investments with their details and action links' do
      expect(response).to have_http_status(:success)
      # summary card details tested in the Summary::Components::Investment spec
      assert_select '.govuk-summary-card'
      assert_select 'h1', 'You have added 1 investment'

      # confirm action are shown
      assert_select 'li.govuk-summary-card__action', count: 2
    end
  end

  describe 'delete a investment' do
    let(:crime_application) { CrimeApplication.first }
    let(:investment) { Investment.first }

    before do
      get confirm_destroy_steps_capital_investments_path(id: crime_application, investment_id: investment)
    end

    it 'allows a user to confirm before deleting a investment' do
      # summary card details tested in the Summary::Components::Investment spec
      assert_select '.govuk-summary-card'
      # confirm action are not shown
      assert_select 'li.govuk-summary-card__action', count: 0

      expect(response.body).to include('Are you sure you want to remove this investment?')
      expect(response.body).to include('Yes, remove it')
      expect(response.body).to include('No, do not remove it')
    end

    context 'when there are other investments' do
      it 'deletes the investment and redirects back to the summary page' do
        # ensure we have at least an additional investment
        investment = crime_application.investments.create!(
          investment_type: InvestmentType::SHARE_ISA,
          ownership_type: 'applicant'
        )

        expect do
          delete steps_capital_investments_path(id: crime_application, investment_id: investment)
        end.to change(Investment, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_capital_investments_summary_path(crime_application))

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the investment'
        end
      end
    end

    context 'when there are no more investments' do
      it 'deletes the investment and redirects to the investment type page' do
        expect do
          delete steps_capital_investments_path(id: crime_application, investment_id: investment)
        end.to change(Investment, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_capital_investment_type_path)

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the investment'
        end
      end
    end
  end
end
