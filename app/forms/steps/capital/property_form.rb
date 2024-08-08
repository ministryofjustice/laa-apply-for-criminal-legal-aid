module Steps
  module Capital
    class PropertyForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include ApplicantOrPartner

      delegate :property_type, to: :record

      attribute :value, :pence
      attribute :outstanding_mortgage, :pence
      attribute :percentage_applicant_owned, :decimal
      attribute :percentage_partner_owned, :decimal
      attribute :is_home_address, :value_object, source: YesNoAnswer
      attribute :has_other_owners, :value_object, source: YesNoAnswer

      validates :value,
                :outstanding_mortgage,
                :percentage_applicant_owned,
                :has_other_owners, presence: true
      validates :is_home_address, presence: true, if: :person_has_home_address?
      validates :is_home_address, inclusion: { in: YesNoAnswer.values }, if: :person_has_home_address?
      validates :has_other_owners, inclusion: { in: YesNoAnswer.values }
      validates :percentage_partner_owned, presence: true, if: :include_partner_in_means_assessment?

      validates_numericality_of :percentage_applicant_owned, greater_than: 0.0,
                                less_than_or_equal_to: 100.0, unless: :include_partner_in_means_assessment?

      validates_numericality_of :percentage_applicant_owned, greater_than_or_equal_to: 0.0,
                                less_than_or_equal_to: 100.0, if: :include_partner_in_means_assessment?
      validates_numericality_of :percentage_partner_owned, greater_than_or_equal_to: 0.0,
                                less_than_or_equal_to: 100.0, if: :include_partner_in_means_assessment?

      validates_with CapitalAssessment::PropertyOwnershipValidator

      def persist!
        record.update(attributes)
      end

      def before_save
        record.address = nil if is_home_address&.yes?
        record.property_owners.destroy_all if has_other_owners&.no?
      end

      def person_has_home_address?
        crime_application.applicant.home_address?
      end
    end
  end
end
