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
        return true unless changed?

        partner.update(attributes.merge(attributes_to_reset))
      end

      def changed?
        !partner.has_nino.eql?(has_nino.to_s) || nino_changed?
      end

      def nino_changed?
        return false if partner.nino.nil? || nino == ''

        partner.nino != nino
      end

      def attributes_to_reset
        nino_attr = partner_has_nino? ? nino : nil

        {
          'benefit_type' => nil,
          'last_jsa_appointment_date' => nil,
          'benefit_check_result' => nil,
          'will_enter_nino' => nil,
          'has_benefit_evidence' => nil,
          'confirm_details' => nil,
          'confirm_dwp_result' => nil,
          'nino' => nino_attr
        }
      end

      def partner_has_nino?
        has_nino&.yes?
      end
    end
  end
end
