module Steps
  module Case
    class IsPreorderWorkClaimedForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      attribute :is_preorder_work_claimed, :value_object, source: YesNoAnswer
      attribute :preorder_work_date, :multiparam_date
      attribute :preorder_work_details, :string

      validates_inclusion_of :is_preorder_work_claimed, in: :choices

      validates :preorder_work_date,
                multiparam_date: true,
                presence: true,
                if: -> { preorder_work_claimed? }

      validates :preorder_work_details, presence: true, if: -> { preorder_work_claimed? }

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
          'preorder_work_date' => (preorder_work_date if preorder_work_claimed?),
          'preorder_work_details' => (preorder_work_details if preorder_work_claimed?)
        }
      end

      def preorder_work_claimed?
        is_preorder_work_claimed&.yes?
      end
    end
  end
end
