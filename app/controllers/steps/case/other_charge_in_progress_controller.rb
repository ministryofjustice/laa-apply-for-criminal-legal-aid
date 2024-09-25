module Steps
  module Case
    class OtherChargeInProgressController < Steps::CaseStepController
      include SubjectResource

      def edit
        @form_object = OtherChargeInProgressForm.new(
          crime_application: current_crime_application,
          subject: @subject
        )
      end

      def update
        update_and_advance(OtherChargeInProgressForm, as: :other_charge_in_progress, subject: @subject)
      end
    end
  end
end
