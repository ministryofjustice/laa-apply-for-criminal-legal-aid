module Steps
  module DWP
    class ConfirmResultPartnerForm < Steps::DWP::ConfirmResultForm
      private

      def update_person_attributes
        crime_application.partner.update(attributes_to_update)
      end
    end
  end
end
