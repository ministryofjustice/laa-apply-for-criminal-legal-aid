module Steps
  module Case
    class AppealDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :appeal_lodged_date, :multiparam_date
      attribute :appeal_with_changes_details, :string
      attribute :appeal_maat_id, :string

      validates :appeal_lodged_date,
                presence: true, multiparam_date: true

      validates :appeal_with_changes_details,
                presence: true, if: -> { appeal_with_changes? }

      def appeal_with_changes?
        case_type.appeal_to_crown_court_with_changes?
      end

      private

      def persist!
        kase.update(
          attributes
        )
      end

      def case_type
        CaseType.new(kase.case_type)
      end
    end
  end
end
