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
                if: -> { case_concluded? }

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
        if case_concluded?
          {
            'date_case_concluded' => date_case_concluded
          }
        else
          {
            'date_case_concluded' => nil,
            'is_preorder_work_claimed' => nil,
            'preorder_work_date' => nil,
            'preorder_work_details' => nil
          }
        end
      end

      def case_concluded?
        has_case_concluded&.yes?
      end
    end
  end
end
