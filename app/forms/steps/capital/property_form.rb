module Steps
  module Capital
    class PropertyForm < Steps::BaseFormObject
      delegate :property_type, to: :record

      CUSTOM_HOUSE_TYPE = 'custom'.freeze

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
      validates :is_home_address, presence: true, if: :person_has_home_address?
      validates :is_home_address, inclusion: { in: YesNoAnswer.values }, if: :person_has_home_address?
      validates :has_other_owners, inclusion: { in: YesNoAnswer.values }
      validates :percentage_partner_owned, presence: true, if: :include_partner?
      validates :custom_house_type, presence: true, if: :custom_house_type?
      validates :house_type, inclusion: {
        in: ->(property) { property.house_types.map(&:to_s).push(Property::CUSTOM_HOUSE_TYPE) }
      }

      def house_types
        HouseType.values
      end

      def persist!
        record.update(attributes)
      end

      def before_save
        record.address = nil if is_home_address.yes?
        record.property_owners.destroy_all if has_other_owners.no?
        self.custom_house_type = nil unless custom_house_type?
      end

      def person_has_home_address?
        crime_application.applicant.home_address?
      end

      # TODO: use proper partner policy once we have one.
      def include_partner?
        YesNoAnswer.new(crime_application.client_has_partner.to_s).yes?
      end

      def custom_house_type?
        house_type == Property::CUSTOM_HOUSE_TYPE
      end
    end
  end
end
