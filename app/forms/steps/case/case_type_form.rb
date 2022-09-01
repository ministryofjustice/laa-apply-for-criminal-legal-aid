module Steps
  module Case
    class CaseTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      attribute :case_type
      attribute :cc_appeal_maat_id
      attribute :cc_appeal_fin_change_maat_id
      attribute :cc_appeal_fin_change_details

      validates :case_type,
                inclusion: { in: :string_choices }

      validates :cc_appeal_fin_change_details,
                presence: true,
                if: -> { case_is_appeal_with_fin_change? }

      has_one_association :case

      def choices
        CaseType.values
      end

      private

      def case_is_appeal_with_fin_change?
        return false if case_type.nil?

        CaseType::CC_APPEAL_FIN_CHANGE.value == case_type.to_sym
      end

      def case_is_appeal?
        return false if case_type.nil?

        CaseType::CC_APPEAL.value == case_type.to_sym
      end

      def string_choices
        choices.map(&:to_s)
      end

      def persist!
        kase.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'cc_appeal_maat_id' => appeal_maat_id,
          'cc_appeal_fin_change_maat_id' => appeal_fin_change_maat_id,
          'cc_appeal_fin_change_details' => appeal_fin_change_details
        }
      end

      def appeal_maat_id
        case_is_appeal? ? cc_appeal_maat_id : nil
      end

      def appeal_fin_change_maat_id
        case_is_appeal_with_fin_change? ? cc_appeal_fin_change_maat_id : nil
      end

      def appeal_fin_change_details
        case_is_appeal_with_fin_change? ? cc_appeal_fin_change_details : nil
      end
    end
  end
end
