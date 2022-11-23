require 'laa_crime_schemas'

module Structs
  class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
    delegate :applicant, to: :client_details
  end
end
