module Steps
  module Income
    class AnswersForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income

      def persist!
        income.valid?(:submission)
      end
    end
  end
end
