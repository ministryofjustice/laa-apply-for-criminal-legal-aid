module Steps
  module Address
    class LookupForm < Steps::BaseFormObject
      attribute :postcode, :string
      validates :postcode, presence: true, uk_postcode: true

      private

      def persist!
        return true unless changed?

        record.update(
          # The following are dependent attributes that need to be reset
          attributes_to_reset.merge(
            postcode:
          )
        )
      end

      def attributes_to_reset
        ::Address::ADDRESS_ATTRIBUTES.zip([]).to_h.merge(
          lookup_id: nil
        )
      end
    end
  end
end
