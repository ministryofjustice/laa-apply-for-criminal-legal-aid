module Steps
  module Capital
    class PropertiesForm < Steps::BaseFormObject
      delegate :property_type, to: :record

      attribute :house_type, :string
      attribute :bedrooms, :integer
      attribute :value, :pence
      attribute :outstanding_mortgage, :pence
      attribute :percentage_applicant_owned, :integer
      attribute :percentage_partner_owned, :integer
      attribute :is_home_address, :value_object, source: YesNoAnswer
      attribute :has_other_owners, :value_object, source: YesNoAnswer

      validates :bedrooms,
                :value,
                :outstanding_mortgage,
                :percentage_applicant_owned,
                :is_home_address,
                :has_other_owners, presence: true
      validates :is_home_address, :has_other_owners, inclusion: { in: YesNoAnswer.values }
      validates :percentage_partner_owned, presence: true, if: :include_partner?

      def persist!
        record.update(attributes)
      end

      # TODO: use proper partner policy once we have one.
      def include_partner?
        YesNoAnswer.new(crime_application.client_has_partner).yes?
      end

      def person_has_home_address?
        crime_application.applicant.home_address?
      end
    end
  end
end
