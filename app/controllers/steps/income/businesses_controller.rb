module Steps
  module Income
    class BusinessesController < Steps::BaseStepController
      include SubjectResource

      def edit
        @form_object = BusinessesForm.build(
          business_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessesForm, record: business_record, as: :businesses
        )
      end

      def destroy
        business_record.destroy

        if businesses.reload.any?
          redirect_to edit_steps_income_businesses_summary_path(subject: @subject), success: t('.success_flash')
        else
          # If this was the last remaining record, redirect to the business type page
          redirect_to edit_steps_income_business_type_path(subject: @subject), success: t('.success_flash')
        end
      end

      def confirm_destroy
        @business = business_record
      end

      private

      def business_record
        @business_record ||= businesses.find(params[:business_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::BusinessNotFound
      end

      def businesses
        @businesses ||= @subject.businesses
      end

      def decision_tree_class
        Decisions::SelfEmployedIncomeDecisionTree
      end
    end
  end
end
