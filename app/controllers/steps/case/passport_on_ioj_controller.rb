module Steps
  module Case
    class PassportOnIojController < Steps::CaseStepController
      def edit
        @form_object = PassportOnIojForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PassportOnIojForm, as: :passport_on_ioj)
      end
    end
  end
end
