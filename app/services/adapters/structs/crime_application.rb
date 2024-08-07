require 'laa_crime_schemas'

module Adapters
  module Structs
    class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
      include TypeOfApplication

      # TODO: remove when partner details CYA work is available
      def partner_detail
        nil
      end

      def applicant
        return @applicant if @applicant

        struct = Structs::Applicant.new(client_details.applicant)

        @applicant = struct
      end

      def partner
        return @partner if @partner
        return nil if client_details.partner.blank?

        struct = Structs::Partner.new(client_details.partner)

        @partner = struct
      end

      def case
        return if pse?

        Structs::CaseDetails.new(case_details)
      end

      alias kase case

      def ioj
        Structs::InterestsOfJustice.new(interests_of_justice)
      end

      def income
        return nil unless means_details

        Structs::IncomeDetails.new(means_details.income_details)
      end

      def outgoings
        return nil unless means_details

        Structs::OutgoingsDetails.new(means_details.outgoings_details)
      end

      def capital
        return nil unless means_details

        @capital ||= Structs::CapitalDetails.new(means_details.capital_details)
      end

      delegate :savings, :investments, :national_savings_certificates, :properties,
               :premium_bonds_total_value, :trust_fund_amount_held, :trust_fund_yearly_dividend,
               :partner_trust_fund_amount_held, :partner_trust_fund_yearly_dividend, to: :capital

      def documents
        supporting_evidence.map do |struct|
          Document.new(
            struct.attributes.merge(submitted_at:)
          )
        end
      end

      def dependants
        return [] unless means_details.income_details.dependants

        means_details.income_details.dependants.map { |struct| Dependant.new(struct.attributes) }
      end

      alias usn reference
    end
  end
end
