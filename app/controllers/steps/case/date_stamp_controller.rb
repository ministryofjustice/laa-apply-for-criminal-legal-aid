module Steps
  module Case
    class DateStampController < Steps::CaseStepController
      def edit
        @form_object = DateStampForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(DateStampForm, as: :date_stamp)
      end
    end
  end
end
