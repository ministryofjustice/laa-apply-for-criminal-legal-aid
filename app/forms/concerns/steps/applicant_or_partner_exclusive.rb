module Steps
  module ApplicantOrPartnerExclusive
    extend ActiveSupport::Concern

    def subject
      I18n.t('dictionary.subject', ownership_type: subject_ownership_type)
    end

    def subject_ownership_type
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
