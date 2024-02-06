module Steps
  module Partner
    class InvolvementController < Steps::PartnerStepController
      def edit
        @form_object = Steps::Partner::InvolvementForm.build(
          partner_details
        )
      end

      def update
        update_and_advance(Steps::Partner::InvolvementForm, as: :involvement)
      end

      private

      def additional_permitted_params
        [:involved_in_case]
      end
    end
  end
end
