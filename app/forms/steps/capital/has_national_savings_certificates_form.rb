module Steps
  module Capital
    class HasNationalSavingsCertificatesForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :capital

      attribute :has_national_savings_certificates, :value_object, source: YesNoAnswer
      validates :has_national_savings_certificates, inclusion: { in: YesNoAnswer.values }

      private

      def persist!
        capital.update(attributes)
      end
    end
  end
end
