module Steps
  module Case
    class CaseTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      attribute :case_type
      attribute :previous_maat_id
      attribute :cc_appeal_fin_change_details

      validates :case_type, presence: true

      has_one_association :case
      alias kase case

      def choices
        CaseType.values
      end

      private

      def persist!
        kase.update(
          attributes
        )
      end
    end
  end
end
