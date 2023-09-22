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
    end
  end
end
