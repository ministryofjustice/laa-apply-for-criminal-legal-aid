module Steps
  module Client
    class AppealFinancialCircumstancesForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      attribute :appeal_financial_circumstances_changed, :value_object, source: YesNoAnswer
      attribute :appeal_with_changes_details, :string

      validates_inclusion_of :appeal_financial_circumstances_changed,
                             in: YesNoAnswer.values,
                             presence: true

      validates :appeal_with_changes_details,
                presence: true, if: -> { financial_circumstances_changed? && changed? }

      private

      def financial_circumstances_changed?
        appeal_financial_circumstances_changed == YesNoAnswer::YES
      end

      def persist!
        return true unless changed?

        self.case.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        if financial_circumstances_changed?
          return {
            'appeal_maat_id' => nil,
            'appeal_usn' => nil,
            'appeal_reference_number' => nil
          }
        end

        {
          'appeal_with_changes_details' => nil
        }
      end
    end
  end
end
