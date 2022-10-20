module Steps
  module Case
    class IojController < Steps::CaseStepController
      def edit
        @form_object = IojForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(IojForm, as: :ioj)
      end

      private

      def additional_permitted_params
        [types: []]
      end
    end
  end
end
