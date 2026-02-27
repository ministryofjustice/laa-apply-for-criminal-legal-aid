module Steps
  module Case
    class IojController < Steps::CaseStepController
      before_action :redirect_cifc

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
        [{ types: [] }]
      end
    end
  end
end
