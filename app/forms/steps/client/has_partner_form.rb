module Steps
  module Client
    class HasPartnerForm < Steps::BaseFormObject
      attribute :client_has_partner, :value_object, source: YesNoAnswer

      validates_inclusion_of :client_has_partner, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def changed?
        !crime_application.client_has_partner.eql?(client_has_partner.to_s)
      end

      # TODO: When FeatureFlag.partner_journey is removed,
      # move this form into /partner and Partner module
      def persist!
        return true unless changed?

        ::CrimeApplication.transaction do
          reset!

          crime_application.update!(
            attributes
          )

          true
        end
      end

      def reset! # rubocop:disable Metrics/AbcSize
        if client_has_partner.no?
          crime_application.partner&.destroy!
          crime_application.partner_detail&.destroy!
          crime_application.income&.update!('partner_employment_status' => [])
          crime_application.payments.for_partner.destroy_all
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
