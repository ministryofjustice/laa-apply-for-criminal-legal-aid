module Steps
  module Income
    class BusinessTypeController < Steps::IncomeStepController
      include SubjectResource

      def edit
        @form_object = BusinessTypeForm.new(
          record: current_crime_application.businesses.new(
            ownership_type: @subject.ownership_type
          ),
          crime_application: current_crime_application,
          subject: @subject
        )
      end

      def update
        update_and_advance(BusinessTypeForm, as: :business_type, subject: @subject)
      end

      private

      def decision_tree_class
        Decisions::SelfEmployedIncomeDecisionTree
      end
    end
  end
end
