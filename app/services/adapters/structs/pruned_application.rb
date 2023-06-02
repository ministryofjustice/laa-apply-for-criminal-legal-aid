require 'laa_crime_schemas'

module Adapters
  module Structs
    class PrunedApplication < LaaCrimeSchemas::Structs::PrunedApplication
      def applicant
        Structs::Applicant.new(client_details.applicant)
      end
    end
  end
end
