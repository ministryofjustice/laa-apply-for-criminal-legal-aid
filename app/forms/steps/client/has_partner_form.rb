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

      def changed?
        !partner_detail.has_partner.eql?(has_partner.to_s)
      end

      private

      def persist! # rubocop:disable Metrics/MethodLength
        return true unless changed?

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
        reset_partner_details
      end

      def reset_partner_details
        partner_detail.update!(
          relationship_to_partner: nil,
          involvement_in_case: nil,
          conflict_of_interest: nil,
          has_same_address_as_client: nil,
          relationship_status: nil,
          separation_date: nil,
          has_partner: 'no',
        )
      end
    end
  end
end
