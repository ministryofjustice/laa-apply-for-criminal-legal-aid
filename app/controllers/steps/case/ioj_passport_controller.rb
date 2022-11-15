module Steps
  module Case
    class IojPassportController < Steps::CaseStepController
      def edit
        @form_object = IojPassportForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(IojPassportForm, as: :ioj_passport)
      end
    end
  end
end
