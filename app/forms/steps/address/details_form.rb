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
        record.update(
          attributes
        )
      end
    end
  end
end
