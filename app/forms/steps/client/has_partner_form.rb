module Steps
  module Client
    class HasPartnerForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner_detail

      attribute :has_partner, :value_object, source: YesNoAnswer

      validates_inclusion_of :has_partner, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        ::CrimeApplication.transaction do
          if has_partner.no?
            reset!
          else
            partner_detail.update!(
              relationship_status: nil,
              separation_date: nil,
              has_partner: 'yes',
            )
          end

          true
        end
      end

      def reset!
        crime_application.partner&.destroy!
        crime_application.income&.update!(partner_employment_status: [])
        crime_application.payments.for_partner.destroy_all
        crime_application.partner_detail&.destroy!
      end
    end
  end
end
