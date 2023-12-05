module Steps
  module Income
    class HasSavingsController < Steps::IncomeStepController
      def edit
        @form_object = HasSavingsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HasSavingsForm, as: :has_savings)
      end
    end
  end
end
