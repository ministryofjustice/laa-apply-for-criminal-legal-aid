module Steps
  module Partner
    class NinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner

      attribute :has_nino, :value_object, source: YesNoAnswer
      attribute :nino, :string

      validates_inclusion_of :has_nino, in: :choices
      validates_with NinoValidator, if: -> { partner_has_nino? }

      def choices
        YesNoAnswer.values
      end

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      private

      def persist!
        partner.update(attributes)
      end

      def partner_has_nino?
        has_nino&.yes?
      end
    end
  end
end
