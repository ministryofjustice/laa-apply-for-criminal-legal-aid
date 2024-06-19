module Steps
  module Income
    class BusinessTypeController < Steps::IncomeStepController
      before_action :set_subject
      before_action :require_no_businesss, except: [:update]

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

      # TODO: extract subject setting etc to concern as pattern evolves.
      #
      def set_subject
        case params[:subject]
        when /client/
          @subject = current_crime_application.applicant
        when /partner/
          raise Errors::SubjectNotFound unless MeansStatus.include_partner?(current_crime_application)

          @subject = current_crime_application.partner
        else
          raise Errors::SubjectNotFound
        end
      end

      def require_no_businesss
        return true if @subject.businesses.empty?

        redirect_to edit_steps_income_businesses_summary_path(
          subject: params[:subject],
          id: current_crime_application
        )
      end

      def decision_tree_class
        Decisions::SelfEmployedIncomeDecisionTree
      end
    end
  end
end
