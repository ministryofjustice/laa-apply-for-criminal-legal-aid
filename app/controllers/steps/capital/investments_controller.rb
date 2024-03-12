module Steps
  module Capital
    class InvestmentsController < Steps::CapitalStepController
      def edit
        @form_object = InvestmentsForm.build(
          investment_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          InvestmentsForm, record: investment_record, as: :investments
        )
      end

      def destroy
        investment_record.destroy

        if investments.reload.any?
          redirect_to edit_steps_capital_investments_summary_path, success: t('.success_flash')
        else
          # If this was the last remaining record, redirect to the investment type page
          redirect_to edit_steps_capital_investment_type_path, success: t('.success_flash')
        end
      end

      def confirm_destroy
        @investment = investment_record
      end

      private

      def investment_record
        @investment_record ||= investments.find(params[:investment_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::InvestmentNotFound
      end

      def investments
        @investments ||= current_crime_application.investments
      end

      def additional_permitted_params
        [:confirm_in_applicants_name]
      end
    end
  end
end
