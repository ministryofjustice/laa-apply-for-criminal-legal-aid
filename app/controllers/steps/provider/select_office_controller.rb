module Steps
  module Provider
    class SelectOfficeController < Steps::ProviderStepController
      def edit
        @form_object = SelectOfficeForm.new(
          record: current_provider
        )
      end

      def update
        update_and_advance(
          SelectOfficeForm, record: current_provider, as: :select_office
        )
      end
    end
  end
end
