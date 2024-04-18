module Steps
  module Capital
    class AnswersForm < Steps::BaseFormObject
      attribute :has_no_other_assets

      validates_with CapitalAssessment::ConfirmationValidator

      delegate :capital, to: :crime_application

      def persist!
        record.valid?(:check_answers) && record.update(attributes)
      end
    end
  end
end
