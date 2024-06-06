module Steps
  module ApplicantOrPartner
    extend ActiveSupport::Concern

    def subject
      I18n.t('dictionary.subject', subject_type: subject_ownership_type)
    end

    def subject_ownership_type
      if include_partner_in_means_assessment?
        SubjectType::APPLICANT_OR_PARTNER
      else
        SubjectType::APPLICANT
      end
    end
  end
end
