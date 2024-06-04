module Steps
  module DWP
    class DWPBaseForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      def ownership_type
        return OwnershipType::PARTNER.to_s if partner_has_benefit?

        OwnershipType::APPLICANT.to_s
      end

      private

      def partner_has_benefit?
        return false if partner.nil?

        partner.has_passporting_benefit?
      end

      def partner
        crime_application.partner
      end
    end
  end
end
