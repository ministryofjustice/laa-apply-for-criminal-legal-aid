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

      def applicant
        Structs::Applicant.new(client_details.applicant)
      end

      def case
        Structs::CaseDetails.new(case_details)
      end

      def ioj
        Structs::InterestsOfJustice.new(interests_of_justice)
      end

      def income
        Structs::IncomeDetails.new(means_details.income_details)
      end

      def outgoings
        Structs::OutgoingsDetails.new(means_details.outgoings_details)
      end

      def outgoings_payments
        return [] unless means_details.outgoings_details.outgoings

        means_details.outgoings_details.outgoings.map do |struct|
          OutgoingsPayment.new(struct.attributes)
        end
      end

      def capital
        @capital ||= Structs::CapitalDetails.new(means_details.capital_details)
      end

      delegate :savings, :investments, :national_savings_certificates, :properties, to: :capital

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
