module SubmissionSerializer
  module Sections
    class OutgoingsDetails < Sections::BaseSection
      def to_builder # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        Jbuilder.new do |json|
          next unless outgoings && requires_full_means_assessment?

          json.outgoings Definitions::Payment.generate(outgoings.outgoings_payments)
          json.housing_payment_type outgoings.housing_payment_type
          json.income_tax_rate_above_threshold outgoings.income_tax_rate_above_threshold

          if include_partner_in_means_assessment?
            json.partner_income_tax_rate_above_threshold outgoings.partner_income_tax_rate_above_threshold
          end

          json.outgoings_more_than_income outgoings.outgoings_more_than_income
          json.how_manage outgoings.how_manage
          json.pays_council_tax outgoings.pays_council_tax
          json.has_no_other_outgoings outgoings.has_no_other_outgoings
        rescue Errors::CannotYetDetermineFullMeans
          next
        end
      end
    end
  end
end
