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

      def income
        Structs::IncomeDetails.new(means_details.income_details)
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
    end
  end
end
