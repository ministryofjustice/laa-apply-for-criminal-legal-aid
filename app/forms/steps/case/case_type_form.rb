module Steps
  module Case
    class CaseTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :case_type, :value_object, source: CaseType

      validates :case_type,
                inclusion: { in: :choices }

      def choices
        CaseType.values
      end

      private

      def changed?
        # The attribute is a `value_object`, overriding generic `#changed?`
        !kase.case_type.eql?(case_type.to_s)
      end

      def persist!
        return true unless changed?

        kase.update(
          attributes.merge(
            # The following are dependent attributes that need to be reset
            appeal_maat_id: nil,
            appeal_lodged_date: nil,
            appeal_with_changes_details: nil,
          )
        )
      end
    end
  end
end
