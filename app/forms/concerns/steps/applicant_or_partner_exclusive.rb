module Steps
  module ApplicantOrPartnerExclusive
    extend ActiveSupport::Concern

    def subject
      I18n.t('dictionary.subject', subject_type: subject_ownership_type)
    end

    def subject_ownership_type
      return SubjectType::PARTNER if partner_has_benefit?

      SubjectType::APPLICANT
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
