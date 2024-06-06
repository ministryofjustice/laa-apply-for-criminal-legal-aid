require 'laa_crime_schemas'

module Adapters
  module Structs
    class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
      include TypeOfApplication

      # TODO: remove when partner details CYA work is available
      def partner_detail
        nil
      end

      # `is_means_tested` is not part of Schema, requires calculation
      # rubocop:disable Naming/PredicateName
      def is_means_tested
        means_passport.include?('on_not_means_tested') ? YesNoAnswer::NO : YesNoAnswer::YES
      end
      # rubocop:enable Naming/PredicateName

      def applicant
        return @applicant if @applicant

        struct = Structs::Applicant.new(client_details.applicant)

        @applicant = struct
      end

      def partner
        return @partner if @partner

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

      def employments
        return [] unless means_details.income_details.employments

        means_details.income_details.employments.map do |struct|
          if struct.respond_to?(:deductions)
            struct.deductions.map! do |deduction|
              Deduction.new(**deduction)
            end
          end
          Employment.new(struct.attributes)
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
