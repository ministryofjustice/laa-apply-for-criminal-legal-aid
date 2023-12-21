require 'laa_crime_schemas'

module Adapters
  module Structs
    class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
      def applicant
        Structs::Applicant.new(client_details.applicant)
      end

      def case
        Structs::CaseDetails.new(case_details)
      end

      def ioj
        Structs::InterestsOfJustice.new(interests_of_justice)
      end

      # client_has_dependants must be calculated, but the dependants
      # data is in means_details rather than means_details.income_details
      def income
        income = Structs::IncomeDetails.new(means_details.income_details)
        income.client_has_dependants = client_has_dependants

        income
      end

      def dependants
        means_details&.dependants&.map { |struct| Dependant.new(**struct) } || []
      end

      def outgoings
        Structs::OutgoingsDetails.new(means_details.outgoings_details)
      end

      def documents
        supporting_evidence.map do |struct|
          Document.new(
            struct.attributes.merge(submitted_at:)
          )
        end
      end

      private

      def client_has_dependants
        return nil unless means_details&.dependants

        if means_details.dependants.size.positive?
          YesNoAnswer::YES
        else
          YesNoAnswer::NO
        end
      end
    end
  end
end
