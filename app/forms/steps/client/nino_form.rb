module Steps
  module Client
    class NinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :has_nino, :value_object, source: YesNoAnswer
      attribute :has_arc, :value_object, source: YesNoAnswer
      attribute :nino, :string
      attribute :arc, :string

      validates :has_arc_or_nino, presence: true
      validates_with NinoValidator, if: -> { client_has_nino? }
      validates_with ArcValidator, if: -> { client_has_arc? }

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      attr_reader :has_arc_or_nino

      def has_arc_or_nino=(value) # rubocop:disable Metrics/MethodLength
        case value
        when 'arc'
          self.has_nino = nil
          self.has_arc = 'yes'
          self.nino = nil
        when 'yes'
          self.has_nino = 'yes'
          self.has_arc = 'no'
          self.arc = nil
        when 'no'
          self.has_nino = 'no'
          self.has_arc = 'no'
          self.nino = nil
          self.arc = nil
        else
          self.has_nino = nil
          self.has_arc = nil
        end
      end

      def has_arc_or_nino # rubocop:disable Lint/DuplicateMethods
        if client_has_arc?
          'arc'
        else
          has_nino
        end
      end

      private

      def changed?
        nino_changed? || arc_changed?
      end

      def nino_changed?
        return false if applicant.has_nino.nil? && has_nino.nil?
        return true unless applicant.has_nino.eql?(has_nino.to_s)

        applicant.nino != nino
      end

      def arc_changed?
        return false unless FeatureFlags.arc.enabled?
        return false if applicant.has_arc == has_arc.to_s

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
        nino_attr = has_arc_or_nino.to_s == 'yes' ? nino : nil
        arc_attr = has_arc_or_nino.to_s == 'arc' ? arc : nil

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
        has_arc&.yes?
      end
    end
  end
end
