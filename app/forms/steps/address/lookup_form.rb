module Steps
  module Address
    class LookupForm < Steps::BaseFormObject
      attribute :postcode, :string
      validates :postcode, presence: true

      private

      def persist!
        return true unless changed?

        record.update(
          attributes.merge(
            # The following are dependent attributes that need to be reset
            address_line_one: nil,
            address_line_two: nil,
            city: nil,
            country: nil,
            lookup_id: nil
          )
        )
      end
    end
  end
end
