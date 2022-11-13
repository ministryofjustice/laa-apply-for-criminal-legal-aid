module Steps
  module Case
    class IojPassportForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :ioj_passport, :value_object, source: IojPassportType

      private

      def persist!
        # If an applicant is passported on ioj, any previously entered ioj type or reason need resetting
        kase.update(
          ioj: nil
        )
      end
    end
  end
end
