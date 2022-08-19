module Steps
  module Client
    class HasPartnerController < Steps::ClientStepController
      def edit
        @form_object = HasPartnerForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HasPartnerForm, as: :has_partner)
      end
    end
  end
end
