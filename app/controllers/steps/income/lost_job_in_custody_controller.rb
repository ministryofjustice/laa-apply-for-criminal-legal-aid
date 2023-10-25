module Steps
  module Income
    class LostJobInCustodyController < Steps::IncomeStepController
      def edit
        @form_object = LostJobInCustodyForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(LostJobInCustodyForm, as: :lost_job_in_custody)
      end
    end
  end
end
