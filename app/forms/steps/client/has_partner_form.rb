module Steps
  module Client
    class HasPartnerForm < Steps::BaseFormObject
      attribute :client_has_partner, :value_object, source: YesNoAnswer

      validates_inclusion_of :client_has_partner, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      # TODO: When FeatureFlag.partner_journey is removed,
      # move this form into /partner and Partner module
      def persist!
        ::CrimeApplication.transaction do
          reset!

          crime_application.update!(
            attributes
          )

          true
        end
      end

      def reset!
        if client_has_partner.no?
          crime_application.partner&.destroy!
          crime_application.partner_detail&.destroy!
        elsif client_has_partner.yes?
          crime_application.partner_detail&.update!(
            'relationship_status' => nil,
            'separation_date' => nil,
            'has_partner' => 'yes',
          )
        end
      end
    end
  end
end
