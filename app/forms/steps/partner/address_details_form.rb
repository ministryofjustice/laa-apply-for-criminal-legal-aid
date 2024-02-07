module Steps
  module Partner
    class AddressDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner

      attribute :different_home_address, :value_object, source: YesNoAnswer

      private

      def persist!
        partner.update(diffent_home_address:)
      end
    end
  end
end

