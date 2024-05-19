module Steps
  module Income
    module Client
      class DeductionsController < Steps::IncomeStepController
        def edit
          @form_object = DeductionsForm.new(
            crime_application: current_crime_application
          )
          @form_object.employment = employment_record
        end

        def update
          update_and_advance(DeductionsForm, as: :client_deductions)
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
          deductions = DeductionType.values.map(&:to_s)
          fieldset_attributes = Steps::Income::Client::DeductionFieldsetForm.attribute_names

          [
            deductions.product([fieldset_attributes]).to_h.merge('types' => [], 'deductions' => [])
          ]
        end
      end
    end
  end
end
