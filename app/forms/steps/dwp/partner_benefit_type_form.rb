module Steps
  module DWP
    class PartnerBenefitTypeForm < Steps::DWP::BenefitTypeForm
      include Steps::HasOneAssociation
      has_one_association :partner

      private

      def changed?
        # The attribute is a `value_object`, overriding generic `#changed?`
        !partner.benefit_type.eql?(benefit_type.to_s) ||
          !partner.last_jsa_appointment_date.eql?(last_jsa_appointment_date)
      end

      def persist!
        return true unless changed?

        partner.update(
          attributes.merge(attributes_to_reset)
        )

        crime_application.update(confirm_dwp_result: nil)
      end
    end
  end
end