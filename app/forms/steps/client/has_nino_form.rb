module Steps
  module Client
    class HasNinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      NINO_REGEXP = /\A(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z][0-9]{6}([A-DFM])\z/

      attribute :has_nino, :value_object, source: YesNoAnswer
      attribute :nino, :string

      # TODO: CRIMAPP-660 clean up code once means journey is enabled
      validates_inclusion_of :has_nino, in: :choices, if: -> { FeatureFlags.means_journey.enabled? }
      validate :validate_nino, if: -> { client_has_nino? }

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
          'passporting_benefit' => nil,
          'nino' => nino_attr
        }
      end

      def client_has_nino?
        return true unless FeatureFlags.means_journey.enabled?

        has_nino&.yes?
      end
    end
  end
end
