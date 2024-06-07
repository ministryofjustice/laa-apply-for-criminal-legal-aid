module Steps
  module Outgoings
    class OutgoingsMoreThanIncomeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      include TypeOfMeansAssessment
      include ApplicantAndPartner

      has_one_association :outgoings

      attribute :outgoings_more_than_income, :value_object, source: YesNoAnswer
      attribute :how_manage, :string

      validates_inclusion_of :outgoings_more_than_income, in: :choices
      validates :how_manage,
                presence: true,
                if: -> { outgoings_more_than_income&.yes? }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        outgoings.update(
          attributes
        )
      end

      def before_save
        return if outgoings_more_than_income&.yes?

        self.how_manage = nil
      end
    end
  end
end
