module Steps
  module Capital
    class AnswersForm < Steps::BaseFormObject
      attribute :has_no_other_assets

      validate do
        CapitalAssessment::ConfirmationValidator.new(self).validate
      end

      delegate :capital, to: :crime_application

      def persist!
        record.valid?(:check_answers) && record.update(attributes)
      end
    end
  end
end
