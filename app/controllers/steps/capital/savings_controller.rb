module Steps
  module Capital
    class SavingsController < Steps::CapitalStepController
      def edit
        @form_object = SavingsForm.build(
          saving_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          SavingsForm, record: saving_record, as: :savings
        )
      end

      private

      def saving_record
        @saving_record ||= savings.find(params[:saving_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::SavingNotFound
      end

      def savings
        @savings ||= current_crime_application.savings
      end

      def additional_permitted_params
        [:confirm_in_applicants_name]
      end
    end
  end
end
