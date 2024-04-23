module Steps
  module Outgoings
    class AnswersForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :outgoings

      def persist!
        outgoings.valid?(:submission)
      end
    end
  end
end
