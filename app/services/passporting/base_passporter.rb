module Passporting
  class BasePassporter
    attr_reader :crime_application

    delegate :applicant, :ioj, to: :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    # :nocov:
    def call
      raise 'implement in subclasses'
    end

    def passported?
      raise 'implement in subclasses'
    end
    # :nocov:

    private

    def applicant_under18?
      applicant.under18?
    end
  end
end
