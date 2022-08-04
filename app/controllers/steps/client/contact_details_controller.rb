module Steps
  module Client
    class ContactDetailsController < Steps::ClientStepController
      def edit
        @form_object = ContactDetailsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ContactDetailsForm, as: :contact_details)
      end
    end
  end
end
