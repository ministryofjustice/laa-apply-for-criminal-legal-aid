module Steps
  module Capital
    class HasNationalSavingsCertificatesController < Steps::CapitalStepController
      def edit
        @form_object = HasNationalSavingsCertificatesForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HasNationalSavingsCertificatesForm, as: :has_national_savings_certificates)
      end
    end
  end
end
