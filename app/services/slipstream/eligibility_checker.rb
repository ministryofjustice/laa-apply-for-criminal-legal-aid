module Slipstream
  class EligibilityChecker
    def initialize(crime_application)
      @crime_application = crime_application
    end

    def eligible?
      selection_reason.present?
    end

    def selection_reason
      return :age if under_18?
      return :offence if single_slipstreamable_offence?

      nil
    end

    private

    attr_reader :crime_application

    def charges
      crime_application.case&.charges.to_a
    end

    def under_18?
      return false unless crime_application.case

      Passporting::IojPassporter.new(crime_application).age_passported?
    end

    def single_slipstreamable_offence?
      charges.one? && charges.all? { |charge| charge.offence&.slipstreamable }
    end
  end
end
