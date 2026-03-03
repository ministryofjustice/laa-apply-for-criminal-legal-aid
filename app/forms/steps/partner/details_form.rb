module Steps
  module Partner
    class DetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :partner

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :other_names, :string
      attribute :date_of_birth, :multiparam_date

      validates_presence_of :first_name, :last_name

      validates :date_of_birth, presence: true, multiparam_date: true

      private

      def persist!
        return true unless changed?

        partner.update(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        return {} unless changed?(:last_name, :date_of_birth)

        {
          has_nino: nil,
          nino: nil,
          has_arc: nil,
          arc: nil,
          will_enter_nino: nil,
          has_benefit_evidence: nil,
          benefit_type: nil,
          last_jsa_appointment_date: nil,
          benefit_check_result: nil,
        }
      end
    end
  end
end
