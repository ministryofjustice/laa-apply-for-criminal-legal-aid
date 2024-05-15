module Steps
  module Income
    module Client
      class EmploymentDetailsController < Steps::IncomeStepController
        def edit
          @form_object = EmploymentDetailsForm.build(
            employment_record, crime_application: current_crime_application
          )
        end

        def update
          if employment_record.income_payment
            employment_record.income_payment.destroy
            employment_record.update(payment_id: nil)
          end
          update_and_advance(EmploymentDetailsForm, record: employment_record, as: :client_employment_details)
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
          [income_payment_attributes: Steps::Income::Client::EmploymentPaymentFieldsetForm.attribute_names]
        end
      end
    end
  end
end
