module Steps
  module Address
    class LookupForm < Steps::BaseFormObject
      attribute :postcode, :string
      validates :postcode, presence: true, uk_postcode: true, unless: :clear_address?

      private

      def persist!
        return true unless clear_address? || changed?

        record.update(
          # The following are dependent attributes that need to be reset
          attributes_to_reset.merge(
            postcode: (postcode unless clear_address?)
          )
        )
      end

      def attributes_to_reset
        ::Address::ADDRESS_ATTRIBUTES.zip([]).to_h.merge(
          lookup_id: nil
        )
      end

      def clear_address?
        step_name.eql?(:clear_address)
      end
    end
  end
end
