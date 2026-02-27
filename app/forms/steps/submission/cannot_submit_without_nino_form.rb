module Steps
  module Submission
    class CannotSubmitWithoutNinoForm < Steps::DWP::CannotCheckBenefitStatusForm
      include Steps::HasOneAssociation

      has_one_association :applicant
    end
  end
end
