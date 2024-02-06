module Steps
  module Partner
    class InvolvementForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner_details, through: :partner

      attribute :involvement_in_case, :value_object, source: InvolvementInCase
      attribute :conflict_of_interest, :string

      validates :involvement_in_case, presence: true, unless: -> { not_involved? }
      validates :conflict_of_interest, presence: true, if: -> { codefendant? }

      def is_involved_in_case=(attr)
        @is_involved_in_case = YesNoAnswer.new(attr)
      end

      def is_involved_in_case
        return @is_involved_in_case unless @is_involved_in_case.nil?

        YesNoAnswer::YES if record.involvement_in_case.present?
      end

      private

      def codefendant?
        involvement_in_case == InvolvementInCase::CODEFENDANT
      end

      def not_involved?
        is_involved_in_case == YesNoAnswer::NO
      end

      def persist!
        self.involvement_in_case = InvolvementInCase::NONE if not_involved?
        self.conflict_of_interest = nil unless codefendant?

        record.update(involvement_in_case:, conflict_of_interest:)
      end
    end
  end
end
