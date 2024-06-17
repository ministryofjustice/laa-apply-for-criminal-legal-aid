module Steps
  module Income
    module Partner
      class DeductionsForm < Steps::Income::Client::DeductionsForm
        private

        def deduction_fieldset_form_name
          DeductionFieldsetForm
        end
      end
    end
  end
end
