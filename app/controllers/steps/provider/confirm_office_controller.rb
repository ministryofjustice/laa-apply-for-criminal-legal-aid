module Steps
  module Provider
    class ConfirmOfficeController < Steps::ProviderStepController
      def edit
        @form_object = ConfirmOfficeForm.new
      end

      def update
        update_and_advance(ConfirmOfficeForm, as: :confirm_office)
      end
    end
  end
end
