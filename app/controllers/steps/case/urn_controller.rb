module Steps
  module Case
    class UrnController < Steps::CaseStepController
      def edit
        @form_object = UrnForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(UrnForm, as: :urn)
      end
    end
  end
end
