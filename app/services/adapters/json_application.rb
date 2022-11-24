module Adapters
  class JsonApplication < BaseApplication
    def initialize(payload)
      super(
        Structs::CrimeApplication.new(payload)
      )
    end
  end
end
