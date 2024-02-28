module Steps
  module Capital
    class PropertiesForm < Steps::BaseFormObject
      delegate :property_type, to: :record

      attribute :house_type, :string
      attribute :custom_house_type, :string
      attribute :bedrooms, :integer
      attribute :value, :pence
      attribute :outstanding_mortgage, :pence
      attribute :percentage_applicant_owned, :integer
      attribute :percentage_partner_owned, :integer
      attribute :is_home_address, :value_object, source: YesNoAnswer
      attribute :has_other_owners, :value_object, source: YesNoAnswer

      validates :house_type,
                :bedrooms,
                :value,
                :outstanding_mortgage,
                :percentage_applicant_owned,
                :has_other_owners, presence: true
      validates :is_home_address, presence: true, if: -> { person_has_home_address? }
      validates :is_home_address, inclusion: { in: YesNoAnswer.values }, if: -> { person_has_home_address? }
      validates :has_other_owners, inclusion: { in: YesNoAnswer.values }
      validates :percentage_partner_owned, presence: true, if: :include_partner?
      validates :custom_house_type, presence: true, unless: -> { house_type_is_listed? }

      def house_types
        HouseType.values
      end

      def persist!
        record.update(attributes)
      end

      def before_save
        self.custom_house_type = nil if house_type_is_listed?
      end

      def person_has_home_address?
        crime_application.applicant.home_address?
      end

      # TODO: use proper partner policy once we have one.
      def include_partner?
        YesNoAnswer.new(crime_application.client_has_partner).yes?
      end

      def house_type_is_listed?
        house_types.map(&:to_s).any? house_type
      end
    end
  end
end
