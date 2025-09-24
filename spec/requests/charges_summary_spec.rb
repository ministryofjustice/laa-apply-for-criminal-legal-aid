require 'rails_helper'

RSpec.describe 'Charges/offences summary page', :authorized do
  before do
    # sets up a few test records
    app = CrimeApplication.create
    kase = Case.create(crime_application: app)

    charge = kase.charges.create!(offence_name: 'Robbery')
    charge.offence_dates.first.update(
      date_from: Date.new(1990, 2, 1), date_to: Date.new(1990, 2, 5)
    )
  end

  after do
    # do not leave leftovers in the test database
    CrimeApplication.destroy_all
  end

  describe 'list of added offences in summary page' do
    let(:crime_application) { CrimeApplication.first }

    before do
      get edit_steps_case_charges_summary_path(crime_application)
    end

    it 'lists the offences with their details and action links' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'You have added 1 offence'

      assert_select '.govuk-summary-card'

      # summary card details tested in the Summary::Components::Offence spec
      assert_select 'li.govuk-summary-card__action', count: 2
    end
  end

  describe 'delete an offence' do
    let(:crime_application) { CrimeApplication.first }
    let(:charge) { Charge.first }

    before do
      get confirm_destroy_steps_case_charges_path(id: crime_application, charge_id: charge)
    end

    it 'allows a user to confirm before deleting an offence' do
      # summary card details tested in the Summary::Components::Offence spec
      assert_select 'li.govuk-summary-card__action', count: 0

      expect(response.body).to include('Are you sure you want to delete this offence?')
      expect(response.body).to include('Yes, delete it')
      expect(response.body).to include('No, do not delete it')
    end

    context 'when there are other offences' do
      it 'deletes the offence and redirects back to the summary page' do
        # ensure we have at least an additional offence
        charge = crime_application.case.charges.create!

        expect do
          delete steps_case_charges_path(id: crime_application, charge_id: charge)
        end.to change(Charge, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_case_charges_summary_path(crime_application))

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'The offence has been deleted'
        end
      end
    end

    context 'when there are no more offences' do
      it 'deletes the offence, creates a brand new one and redirects to the offence page' do
        expect do
          delete steps_case_charges_path(id: crime_application, charge_id: charge)
        end.not_to change(Charge, :count)

        new_charge = Charge.last

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_case_charges_path(id: crime_application, charge_id: new_charge))

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'The offence has been deleted'
        end
      end
    end
  end
end
