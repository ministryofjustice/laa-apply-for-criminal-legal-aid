module Slipstream
  class EligibilityChecker
    def initialize(crime_application)
      @crime_application = crime_application
    end

    def eligible?
      charges.one? && charges.all? { |charge| charge.offence&.slipstreamable }
    end

    private

    attr_reader :crime_application

    def charges
      crime_application.case&.charges.to_a
    end
  end
end
