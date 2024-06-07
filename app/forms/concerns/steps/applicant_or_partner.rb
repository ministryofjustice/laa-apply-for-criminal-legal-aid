module Steps
  module ApplicantOrPartner
    extend ActiveSupport::Concern

    def subject
      I18n.t('dictionary.subject', subject_type: form_subject)
    end

    def form_subject
      if include_partner_in_means_assessment?
        SubjectType::APPLICANT_OR_PARTNER
      else
        SubjectType::APPLICANT
      end
    end
  end
end
