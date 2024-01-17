module Steps
  module Case
    class HasCaseConcludedForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :has_case_concluded, :value_object, source: YesNoAnswer
      attribute :date_case_concluded, :multiparam_date

      validates_inclusion_of :has_case_concluded, in: :choices

      validates :date_case_concluded,
                multiparam_date: true,
                presence: true,
                if: -> { has_case_concluded }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        self.case.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'date_case_concluded' => (date_case_concluded if has_case_concluded)
        }
      end

      def has_case_concluded?
        has_case_concluded&.yes?
      end
    end
  end
end
