module Steps
  module Income
    class EmployerDetailsController < Steps::IncomeStepController
      def edit
        @form_object = EmployerDetailsForm.build(
          employment_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(EmployerDetailsForm, record: employment_record, as: :client_employer_details)
      end

      private

      def employment_record
        @employment_record ||= employments.find(params[:employment_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::EmploymentNotFound
      end

      def employments
        @employments ||= current_crime_application.employments
      end

      def additional_permitted_params
        [address: [:address_line_one, :address_line_two, :city, :country, :postcode]]
      end
    end
  end
end
