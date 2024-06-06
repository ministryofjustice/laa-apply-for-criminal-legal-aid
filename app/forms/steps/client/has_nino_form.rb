module Steps
  module Client
    class HasNinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      NINO_REGEXP = /\A(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z][0-9]{6}([A-DFM])\z/

      attribute :has_nino, :value_object, source: YesNoAnswer
      attribute :nino, :string

      validates_inclusion_of :has_nino, in: :choices
      validate :validate_nino, if: -> { client_has_nino? }
      # TODO: Use NinoValidator CRIMAPP-970

      def choices
        YesNoAnswer.values
      end

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      private

      def validate_nino
        if nino.blank?
          crime_application.not_means_tested? ? return : errors.add(:nino, :blank)
        end

        errors.add(:nino, :invalid) unless NINO_REGEXP.match?(nino)
      end

      def changed?
        !applicant.has_nino.eql?(has_nino.to_s) || nino_changed?
      end

      def nino_changed?
        return false if applicant.nino.nil? && nino == ''

        applicant.nino != nino
      end

      def persist!
        return true unless changed?

        applicant.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        nino_attr = client_has_nino? ? nino : nil

        {
          # The following are dependent attributes that need to be reset
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

      def client_has_nino?
        has_nino&.yes?
      end
    end
  end
end
