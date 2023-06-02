module Adapters
  class JsonApplication < BaseApplication
    def initialize(payload)
      super(
        struct_for(payload)
      )
    end

    private

    def struct_for(payload)
      if payload.key?('case_details')
        Structs::CrimeApplication.new(payload)
      else
        Structs::PrunedApplication.new(payload)
      end
    end
  end
end
