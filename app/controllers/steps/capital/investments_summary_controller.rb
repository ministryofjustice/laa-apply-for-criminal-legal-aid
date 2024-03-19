module Steps
  module Capital
    class InvestmentsSummaryController < Steps::CapitalStepController
      def edit
        @form_object = InvestmentsSummaryForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(InvestmentsSummaryForm, as: :investments_summary)
      end

      private

      def additional_permitted_params
        [:add_investment]
      end
    end
  end
end
