module Steps
  module Income
    class EmployerDetailsForm < Steps::BaseFormObject
      validates :employer_name, presence: true

      attribute :employer_name
      attribute :address

      attribute :address_line_one
      attribute :address_line_two
      attribute :city
      attribute :country
      attribute :postcode

      validates_with AddressValidator

      def persist!
        record.update(attributes)
      end
    end
  end
end
