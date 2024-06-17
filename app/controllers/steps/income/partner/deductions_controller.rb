module Steps
  module Income
    module Partner
      class DeductionsController < Steps::Income::Client::DeductionsController
        private

        def advance_as
          :partner_deductions
        end

        def form_name
          Steps::Income::Partner::DeductionsForm
        end

        def deduction_fieldset_form_name
          Steps::Income::Partner::DeductionFieldsetForm
        end

        def employments
          @employments ||= current_crime_application.partner_employments
        end
      end
    end
  end
end
