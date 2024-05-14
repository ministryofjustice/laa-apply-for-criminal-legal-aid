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
          employment_record.payments.destroy_all
          current_crime_application.income_payments
                                   .where(payment_type: IncomePaymentType::EMPLOYMENT_DETAILS.to_s)
                                   .destroy_all
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
          [payments_attributes: Steps::Income::Client::PaymentFieldsetForm.attribute_names]
        end
      end
    end
  end
end
