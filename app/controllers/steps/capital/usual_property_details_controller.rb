module Steps
  module Capital
    class UsualPropertyDetailsController < Steps::CapitalStepController
      def edit
        @form_object = UsualPropertyDetailsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(UsualPropertyDetailsForm, as: :usual_property_details)
      end

      private

      def additional_permitted_params
        [:action]
      end
    end
  end
end
