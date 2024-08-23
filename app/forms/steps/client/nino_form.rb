module Steps
  module Client
    class NinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :has_nino, :value_object, source: HasNinoType
      attribute :nino, :string
      attribute :arc, :string

      validates_inclusion_of :has_nino, in: :choices
      validates_with NinoValidator, if: -> { client_has_nino? }
      validates_with ArcValidator, if: -> { client_has_arc? }

      def choices
        HasNinoType.values
      end

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      private

      def changed?
        !applicant.has_nino.eql?(has_nino.to_s) || nino_changed? || arc_changed?
      end

      def nino_changed?
        return false if applicant.nino.nil? && nino == ''

        applicant.nino != nino
      end

      def arc_changed?
        return false if applicant.arc.nil? || arc == ''

        applicant.arc != arc
      end

      def persist!
        return true unless changed?

        applicant.update(
          attributes.merge(attributes_to_reset)
        )
      end

      # rubocop:disable Metrics/MethodLength
      def attributes_to_reset
        nino_attr = client_has_nino? ? nino : nil
        arc_attr = client_has_arc? ? arc : nil

        {
          # The following are dependent attributes that need to be reset
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

      def client_has_nino?
        has_nino&.yes?
      end

      def client_has_arc?
        has_nino&.arc?
      end
    end
  end
end
