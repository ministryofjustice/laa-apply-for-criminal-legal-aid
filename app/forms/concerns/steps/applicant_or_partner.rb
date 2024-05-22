module Steps
  module ApplicantOrPartner
    extend ActiveSupport::Concern

    def subject
      I18n.t('dictionary.subject', ownership_type: subject_ownership_type)
    end

    def subject_ownership_type
      if include_partner_in_means_assessment?
        OwnershipType::APPLICANT_AND_PARTNER.to_s
      else
        OwnershipType::APPLICANT.to_s
      end
    end
  end
end
