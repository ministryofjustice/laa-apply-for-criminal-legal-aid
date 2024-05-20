module Steps
  module Income
    module Client
      class EmployerDetailsForm < Steps::BaseFormObject
        attribute :employer_name
        attribute :address

        attribute :address_line_one
        attribute :address_line_two
        attribute :city
        attribute :country
        attribute :postcode

        validates :employer_name, :address, presence: true
        validates_with AddressValidator

        def persist!
          record.update(attributes)
        end
      end
    end
  end
end
