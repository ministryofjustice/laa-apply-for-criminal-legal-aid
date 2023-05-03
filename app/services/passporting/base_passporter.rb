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

    def passport_types_collection
      raise 'implement in subclasses'
    end
    # :nocov:

    private

    def resubmission?
      crime_application.parent_id.present?
    end

    def applicant_under18?
      applicant.under18?
    end

    def passported_on?(kind)
      passport_types_collection.include?(kind.to_s)
    end
  end
end
