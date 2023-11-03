module Steps
  module Income
    class ManageWithoutIncomeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :manage_without_income, :value_object, source: ManageWithoutIncomeType
      attribute :manage_other_details, :string

      validates_inclusion_of :manage_without_income, in: :choices

      validates :manage_other_details,
                presence: true,
                if: -> { manage_other? }

      def choices
        ManageWithoutIncomeType.values
      end

      private

      def persist!
        applicant.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'manage_other_details' => (manage_other_details if manage_other?)
        }
      end

      def manage_other?
        manage_without_income&.other?
      end
    end
  end
end
