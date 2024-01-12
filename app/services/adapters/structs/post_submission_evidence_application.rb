require 'laa_crime_schemas'

module Adapters
  module Structs
    class PostSubmissionEvidenceApplication < LaaCrimeSchemas::Structs::CrimeApplication
      def applicant
        Structs::Applicant.new(client_details.applicant)
      end

      def documents
        supporting_evidence.map do |struct|
          Document.new(
            struct.attributes.merge(submitted_at:)
          )
        end
      end

      def initial?
        false
      end
    end
  end
end
