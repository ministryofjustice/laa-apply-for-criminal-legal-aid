module Steps
  module Capital
    class HasNationalSavingsCertificatesController < Steps::CapitalStepController
      before_action :require_no_certificates

      def edit
        @form_object = HasNationalSavingsCertificatesForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HasNationalSavingsCertificatesForm, as: :has_national_savings_certificates)
      end

      private

      def require_no_certificates
        return true if current_crime_application.capital.national_savings_certificates.empty?

        redirect_to edit_steps_capital_national_savings_certificates_summary_path(
          current_crime_application
        )
      end
    end
  end
end
