module Steps
  module ApplicantAndPartner
    extend ActiveSupport::Concern

    def subject_ownership_type
      if include_partner_in_means_assessment?
        SubjectType::APPLICANT_AND_PARTNER
      else
        SubjectType::APPLICANT
      end
    end
  end
end
