module Steps
  module Partner
    class ConflictForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :partner_detail

      attribute :conflict_of_interest, :value_object, source: YesNoAnswer
      validates :conflict_of_interest, inclusion: { in: :choices }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        partner_detail.update(attributes)
      end
    end
  end
end
