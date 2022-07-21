module Steps
  module Client
    class HasPartnerController < Steps::ClientStepController
      # This is just to speed up the demo until we create a proper case initialisation mechanism,
      # probably a POST from the provider list of cases (`Make a new application` button)
      include StartingPointStep

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
