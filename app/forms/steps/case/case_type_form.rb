module Steps
  module Case
    class CaseTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :case_type, :value_object, source: CaseType
      attribute :cc_appeal_maat_id, :string
      attribute :cc_appeal_fin_change_maat_id, :string
      attribute :cc_appeal_fin_change_details, :string

      validates :case_type,
                inclusion: { in: :choices }

      validates :cc_appeal_fin_change_details,
                presence: true,
                if: -> { case_type&.appeal_to_crown_court_with_changes? }

      def choices
        CaseType.values
      end

      private

      def persist!
        kase.update(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'cc_appeal_maat_id' => appeal_maat_id,
          'cc_appeal_fin_change_maat_id' => appeal_fin_change_maat_id,
          'cc_appeal_fin_change_details' => appeal_fin_change_details
        }
      end

      def appeal_maat_id
        case_type.appeal_to_crown_court? ? cc_appeal_maat_id : nil
      end

      def appeal_fin_change_maat_id
        case_type.appeal_to_crown_court_with_changes? ? cc_appeal_fin_change_maat_id : nil
      end

      def appeal_fin_change_details
        case_type.appeal_to_crown_court_with_changes? ? cc_appeal_fin_change_details : nil
      end
    end
  end
end
