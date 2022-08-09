module Steps
  module Address
    class DetailsForm < Steps::BaseFormObject
      attribute :address_line_one, :string
      attribute :address_line_two, :string
      attribute :city, :string
      attribute :country, :string
      attribute :postcode, :string

      validates_presence_of :address_line_one,
                            :city,
                            :country,
                            :postcode

      private

      def persist!
        return true unless changed?

        record.update(
          attributes.merge(
            # The following are dependent attributes that need to be reset
            lookup_id: nil
          )
        )
      end
    end
  end
end
