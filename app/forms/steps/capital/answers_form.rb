module Steps
  module Capital
    class AnswersForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include ApplicantAndPartner

      include Steps::HasOneAssociation

      has_one_association :capital

      attribute :has_no_other_assets

      validate do
        CapitalAssessment::ConfirmationValidator.new(self).validate
      end

      def persist!
        capital.valid?(:check_answers) && capital.update(has_no_other_assets:)
      end
    end
  end
end
