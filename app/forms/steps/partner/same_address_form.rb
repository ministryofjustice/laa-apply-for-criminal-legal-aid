module Steps
  module Partner
    class SameAddressForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner_detail

      attribute :same_address_as_client, :value_object, source: YesNoAnswer
      validates :same_address_as_client, inclusion: { in: :choices }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        partner_detail.update(attributes)
      end
    end
  end
end
