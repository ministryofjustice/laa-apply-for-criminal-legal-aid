require 'rails_helper'

RSpec.describe 'NationalSavingsCertificates summary page', :authorized do
  include_context 'with office code selected'

  before do
    allow(MeansStatus).to receive(:full_capital_required?).and_return('true')

    app = CrimeApplication.create(
      office_code: selected_office_code,
      capital: Capital.new(has_national_savings_certificates: 'yes')
    )
    app.national_savings_certificates.create!(
      holder_number: 'A!',
      certificate_number: 'B2',
      value: 10_001,
      ownership_type: OwnershipType::APPLICANT
    )
  end

  describe 'list of added certificates on summary page' do
    let(:crime_application) { CrimeApplication.first }

    before do
      get edit_steps_capital_national_savings_certificates_summary_path(crime_application)
    end

    it 'lists the certificates with their details and action links' do
      expect(response).to have_http_status(:success)
      # summary card details tested in the Summary::Components::NationalSavingsCertificate spec
      assert_select '.govuk-summary-card'
      assert_select 'h1', 'You have added 1 National Savings Certificate'

      # confirm action are shown
      assert_select 'li.govuk-summary-card__action', count: 2
    end
  end

  describe 'delete a national_savings_certificate' do
    let(:crime_application) { CrimeApplication.first }
    let(:certificate) { NationalSavingsCertificate.first }

    let(:confirm_path) do
      confirm_destroy_steps_capital_national_savings_certificates_path(
        id: crime_application, national_savings_certificate_id: certificate
      )
    end

    let(:destroy_path) do
      steps_capital_national_savings_certificates_path(
        id: crime_application, national_savings_certificate_id: certificate
      )
    end

    before do
      get confirm_path
    end

    it 'allows a user to confirm before deleting a certificate' do
      # summary card details tested in the Summary::Components::NationalSavingsCertificate spec
      assert_select '.govuk-summary-card'
      # confirm action are not shown
      assert_select 'li.govuk-summary-card__action', count: 0

      expect(response.body).to include('Are you sure you want to remove this National Savings Certificate?')
      expect(response.body).to include('Yes, remove it')
      expect(response.body).to include('No, do not remove it')
    end

    context 'when there are other certificates' do
      it 'deletes the certificate and redirects back to the summary page' do
        # ensure we have at least an additional certificate
        crime_application.national_savings_certificates.create!(ownership_type: 'applicant')

        expect { delete destroy_path }.to change(NationalSavingsCertificate, :count).by(-1)
        expect(response).to have_http_status(:redirect)

        expect(response).to redirect_to(
          edit_steps_capital_national_savings_certificates_summary_path(crime_application)
        )

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the National Savings Certificate'
        end
      end
    end

    context 'when there are no more certificates' do
      it 'deletes the certificate and redirects to the has_national_savings_certicates page' do
        expect { delete destroy_path }.to change(NationalSavingsCertificate, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_capital_has_national_savings_certificates_path)

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the National Savings Certificate'
        end
      end
    end
  end
end
