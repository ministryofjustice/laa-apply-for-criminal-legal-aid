module Steps
  module Income
    class BusinessesSummaryController < Steps::BaseStepController
      include SubjectResource

      before_action :require_businesses

      def edit
        @form_object = BusinessesSummaryForm.build(@subject)
      end

      def update
        update_and_advance(BusinessesSummaryForm, as: :businesses_summary, record: @subject)
      end

      private

      def additional_permitted_params
        [:add_business]
      end

      def require_businesses
        return true if @subject.businesses.present?

        redirect_to edit_steps_income_business_type_path(
          current_crime_application, @subject
        )
      end

      def decision_tree_class
        Decisions::SelfEmployedIncomeDecisionTree
      end
    end
  end
end
