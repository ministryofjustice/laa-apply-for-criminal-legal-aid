module Steps
  module DWP
    class ConfirmResultController < Steps::DWPStepController
      def edit
        @form_object = ConfirmResultForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ConfirmResultForm, as: :confirm_result)
      end

      # def step_name
      #   if params.key?('confirm_dwp_result')
      #     throw 'here'
      #   else
      #     :confirm_result
      #   end
      # end
    end
  end
end
