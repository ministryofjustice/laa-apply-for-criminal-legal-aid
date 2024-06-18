module Steps
  module Income
    module Client
      class DeductionsController < Steps::IncomeStepController
        include Steps::Income::EmploymentUpdateStep

        def edit
          @form_object = form_name.new(
            crime_application: current_crime_application
          )
          @form_object.employment = employment_record
        end

        def update
          update_and_advance(form_name, as: advance_as)
        end

        private

        def advance_as
          :client_deductions
        end

        def form_name
          Steps::Income::Client::DeductionsForm
        end

        def deduction_fieldset_form_name
          Steps::Income::Client::DeductionFieldsetForm
        end

        def employments
          @employments ||= current_crime_application.employments
        end

        def additional_permitted_params
          deductions = DeductionType.values.map(&:to_s)
          fieldset_attributes = deduction_fieldset_form_name.attribute_names

          [
            deductions.product([fieldset_attributes]).to_h.merge('types' => [], 'deductions' => [])
          ]
        end
      end
    end
  end
end
