module Steps
  module Partner
    class NinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner

      attribute :has_nino, :value_object, source: HasNinoType
      attribute :nino, :string
      attribute :arc, :string

      validates_inclusion_of :has_nino, in: :choices
      validates_with NinoValidator, if: -> { partner_has_nino? }
      validates_with ArcValidator, if: -> { partner_has_arc? }

      def choices
        values = HasNinoType.values.dup
        values.delete(HasNinoType::ARC) unless FeatureFlags.arc.enabled?

        values
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
        !partner.has_nino.eql?(has_nino.to_s) || nino_changed? || arc_changed?
      end

      def nino_changed?
        return false if partner.nino.nil? || nino == ''

        partner.nino != nino
      end

      def arc_changed?
        return false if partner.arc.nil? || arc == ''

        partner.arc != arc
      end

      # rubocop:disable Metrics/MethodLength
      def attributes_to_reset
        nino_attr = partner_has_nino? ? nino : nil
        arc_attr = partner_has_arc? ? arc : nil

        {
          'benefit_type' => nil,
          'last_jsa_appointment_date' => nil,
          'benefit_check_result' => nil,
          'will_enter_nino' => nil,
          'has_benefit_evidence' => nil,
          'confirm_details' => nil,
          'confirm_dwp_result' => nil,
          'nino' => nino_attr,
          'arc' => arc_attr
        }
      end
      # rubocop:enable Metrics/MethodLength

      def partner_has_nino?
        has_nino&.yes?
      end

      def partner_has_arc?
        has_nino&.arc?
      end
    end
  end
end
