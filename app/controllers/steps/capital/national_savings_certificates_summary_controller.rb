module Steps
  module Capital
    class NationalSavingsCertificatesSummaryController < Steps::CapitalStepController
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
    end
  end
end
