module Steps
  module Shared
    class NinoForm < Steps::BaseFormObject
      attribute :has_nino, :value_object, source: YesNoAnswer
      attribute :has_arc, :value_object, source: YesNoAnswer
      attribute :nino, :string
      attribute :arc, :string

      validates :has_arc_or_nino, presence: true
      validates_with NinoValidator, if: -> { has_nino? }
      validates_with ArcValidator, if: -> { has_arc? }

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      def arc=(str)
        super(str.upcase.delete(' ')) if str
      end

      def has_arc_or_nino=(value) # rubocop:disable Metrics/MethodLength
        self.nino = nil unless value == 'yes'
        self.arc = nil unless value == 'arc'

        case value
        when 'arc'
          self.has_nino = nil
          self.has_arc = 'yes'
        when 'yes'
          self.has_nino = 'yes'
          self.has_arc = 'no'
        when 'no'
          self.has_nino = 'no'
          self.has_arc = 'no'
        else
          self.has_nino = nil
          self.has_arc = nil
        end
      end

      def has_arc_or_nino
        return 'arc' if has_arc?

        has_nino
      end

      def form_subject
        SubjectType.new(record.ownership_type)
      end

      private

      def changed?
        nino_changed? || arc_changed?
      end

      def nino_changed?
        return false if record.has_nino.nil? && has_nino.nil?
        return true unless record.has_nino.eql?(has_nino.to_s)

        record.nino != nino
      end

      def arc_changed?
        return false if record.has_arc == has_arc.to_s

        record.arc != arc
      end

      def persist!
        return true unless changed?

        record.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          # The following are dependent attributes that need to be reset
          'benefit_type' => nil,
          'last_jsa_appointment_date' => nil,
          'benefit_check_result' => nil,
          'will_enter_nino' => nil,
          'has_benefit_evidence' => nil,
          'confirm_details' => nil,
          'confirm_dwp_result' => nil,
        }
      end

      def has_nino?
        has_nino&.yes?
      end

      def has_arc?
        has_arc&.yes?
      end
    end
  end
end
