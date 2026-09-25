module Steps
  module Income
    module Client
      class EmployerDetailsForm < Steps::BaseFormObject
        attribute :employer_name

        attribute :address_line_one
        attribute :address_line_two
        attribute :city
        attribute :country
        attribute :postcode

        validates :employer_name, presence: true
        validates :address_line_one, :city, :country, :postcode, presence: true

        def persist!
          record.update(attributes)
        end
      end
    end
  end
end
