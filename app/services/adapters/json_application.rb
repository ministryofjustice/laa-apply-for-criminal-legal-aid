module Adapters
  class JsonApplication < BaseApplication
    delegate :applicant, to: :client_details

    def initialize(payload)
      super(
        Structs::CrimeApplication.new(payload)
      )
    end
  end
end
