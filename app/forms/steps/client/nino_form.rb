module Steps
  module Client
    class NinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :has_nino, :value_object, source: YesNoAnswer
      attribute :nino, :string

      validates_inclusion_of :has_nino, in: :choices
      validates_with NinoValidator, person: :applicant, if: -> { client_has_nino? }

      def choices
        YesNoAnswer.values
      end

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      private

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
        crime_application.update(confirm_dwp_result: nil)
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
          'nino' => nino_attr
        }
      end

      def client_has_nino?
        has_nino&.yes?
      end
    end
  end
end
