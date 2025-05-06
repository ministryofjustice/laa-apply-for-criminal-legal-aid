module Steps
  module DWP
    class PartnerConfirmResultForm < Steps::DWP::ConfirmResultForm
      include Steps::HasOneAssociation
      has_one_association :partner

      private

      def update_person_attributes
        partner.update(attributes_to_update)
      end
    end
  end
end
