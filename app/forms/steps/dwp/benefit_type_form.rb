module Steps
  module DWP
    class BenefitTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :benefit_type, :value_object, source: BenefitType
      attribute :last_jsa_appointment_date, :multiparam_date

      validates :benefit_type,
                inclusion: { in: :choices }

      validates :last_jsa_appointment_date,
                multiparam_date: true,
                presence: true,
                if: -> { jsa? }

      def choices
        BenefitType.values
      end

      private

      def changed?
        # The attribute is a `value_object`, overriding generic `#changed?`
        !applicant.benefit_type.eql?(benefit_type.to_s) ||
          !applicant.last_jsa_appointment_date.eql?(last_jsa_appointment_date)
      end

      def persist!
        return true unless changed?

        applicant.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'last_jsa_appointment_date' => (last_jsa_appointment_date if jsa?),
          'has_benefit_evidence' => nil,
        }
      end

      def jsa?
        benefit_type&.jsa?
      end
    end
  end
end
