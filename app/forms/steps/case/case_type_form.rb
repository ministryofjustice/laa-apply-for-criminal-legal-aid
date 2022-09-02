module Steps
  module Case
    class CaseTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      attribute :case_type, type: :string
      attribute :cc_appeal_maat_id, type: :string
      attribute :cc_appeal_fin_change_maat_id, type: :string
      attribute :cc_appeal_fin_change_details, type: :string

      validates :case_type,
                inclusion: { in: :string_choices }

      validates :cc_appeal_fin_change_details,
                presence: true,
                if: -> { case_type.present? && case_type_val.cc_appeal_fin_change? }

      has_one_association :case

      def choices
        CaseType.values
      end

      private

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
        case_type_val.new(case_type).cc_appeal? ? cc_appeal_maat_id : nil
      end

      def appeal_fin_change_maat_id
        case_type_val.new(case_type).cc_appeal_fin_change? ? cc_appeal_fin_change_maat_id : nil
      end

      def appeal_fin_change_details
        case_type_val.cc_appeal_fin_change? ? cc_appeal_fin_change_details : nil
      end

      def case_type_val
        CaseType.new(case_type)
      end
    end
  end
end
