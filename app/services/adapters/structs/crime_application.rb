require 'laa_crime_schemas'

module Adapters
  module Structs
    class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
      include TypeOfApplication
      # `is_means_tested` is not part of Schema, requires calculation
      # rubocop:disable Naming/PredicateName
      def is_means_tested
        means_passport.include?('on_not_means_tested') ? YesNoAnswer::NO : YesNoAnswer::YES
      end
      # rubocop:enable Naming/PredicateName

      # `confirm_dwp_result` is saved in the applicant/partner part of Schema, requires calculation
      # TODO: amend for partner
      def confirm_dwp_result
        client_details.applicant.respond_to?(:confirm_dwp_result) ? client_details.applicant.confirm_dwp_result : nil
      end

      # `passporting_benefit` not part of schema, infer true value if
      # means passport is on benefit check. We cannot infer false from
      # the information we have, so default to nil
      def infer_passporting_benefit
        true if means_passport.include?(MeansPassportType::ON_BENEFIT_CHECK.to_s)
      end

      def applicant
        return @applicant if @applicant

        struct = Structs::Applicant.new(client_details.applicant)
        struct.passporting_benefit = infer_passporting_benefit

        @applicant = struct
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

      def income_payments
        return [] unless means_details.income_details.income_payments

        means_details.income_details.income_payments.map do |struct|
          IncomePayment.new(struct.attributes)
        end
      end

      def income_benefits
        return [] unless means_details.income_details.income_benefits

        means_details.income_details.income_benefits.map do |struct|
          IncomeBenefit.new(struct.attributes)
        end
      end

      def outgoings
        return nil unless means_details

        Structs::OutgoingsDetails.new(means_details.outgoings_details)
      end

      def outgoings_payments
        return [] unless means_details.outgoings_details.outgoings

        means_details.outgoings_details.outgoings.map do |struct|
          OutgoingsPayment.new(struct.attributes)
        end
      end

      def capital
        return nil unless means_details

        @capital ||= Structs::CapitalDetails.new(means_details.capital_details)
      end

      delegate :savings, :investments, :national_savings_certificates, :properties,
               :premium_bonds_total_value, :trust_fund_amount_held, :trust_fund_yearly_dividend, to: :capital

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
