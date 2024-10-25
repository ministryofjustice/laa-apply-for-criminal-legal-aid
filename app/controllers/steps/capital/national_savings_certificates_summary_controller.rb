module Steps
  module Capital
    class NationalSavingsCertificatesSummaryController < Steps::CapitalStepController
      before_action :require_certificates

      def edit
        @form_object = NationalSavingsCertificatesSummaryForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(NationalSavingsCertificatesSummaryForm, as: :national_savings_certificates_summary)
      end

      private

      def additional_permitted_params
        [:add_national_savings_certificate]
      end

      def require_certificates
        return true if current_crime_application.capital.national_savings_certificates.present?

        redirect_to edit_steps_capital_has_national_savings_certificates_path(current_crime_application)
      end
    end
  end
end
