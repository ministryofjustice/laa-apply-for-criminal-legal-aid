module Steps
  module Case
    class CaseTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      attribute :case_type
      attribute :previous_maat_id
      attribute :cc_appeal_fin_change_details

      validates :case_type,
                inclusion: { in: :string_choices }

      validates :previous_maat_id,
                absence: true,
                unless: -> { case_is_an_appeal_type? }

      validates :cc_appeal_fin_change_details,
                absence: true,
                unless: -> { case_is_appeal_with_financial_change? }

      validates :cc_appeal_fin_change_details,
                presence: true,
                if: -> { case_is_appeal_with_financial_change? }

      has_one_association :case

      def choices
        CaseType.values
      end

      private

      def case_is_an_appeal_type?
        return false if case_type.nil?

        [CaseType::CC_APPEAL.value,
         CaseType::CC_APPEAL_FIN_CHANGE.value].include?(case_type.to_sym)
      end

      def case_is_appeal_with_financial_change?
        return false if case_type.nil?

        CaseType::CC_APPEAL_FIN_CHANGE.value == case_type.to_sym
      end

      def string_choices
        choices.map(&:to_s)
      end

      def persist!
        kase.update(
          attributes
        )
      end
    end
  end
end
