module Steps
  module Case
    class CaseTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :case_type, :value_object, source: CaseType
      attribute :appeal_maat_id, :string
      attribute :appeal_with_changes_maat_id, :string
      attribute :appeal_with_changes_details, :string

      validates :case_type,
                inclusion: { in: :choices }

      validates :appeal_with_changes_details,
                presence: true,
                if: -> { appeal_with_changes? }

      def choices
        CaseType.values
      end

      private

      def persist!
        kase.update(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'appeal_maat_id' => (appeal_maat_id if appeal?),
          'appeal_with_changes_maat_id' => (appeal_with_changes_maat_id if appeal_with_changes?),
          'appeal_with_changes_details' => (appeal_with_changes_details if appeal_with_changes?),
        }
      end

      def appeal?
        case_type&.appeal_to_crown_court?
      end

      def appeal_with_changes?
        case_type&.appeal_to_crown_court_with_changes?
      end
    end
  end
end
