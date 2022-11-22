require 'laa_crime_schemas'

module Adapters
  class JsonApplication < BaseApplication
    delegate :applicant, to: :client_details

    def initialize(payload)
      super(
        LaaCrimeSchemas::Structs::CrimeApplication.new(payload)
      )
    end
  end
end
