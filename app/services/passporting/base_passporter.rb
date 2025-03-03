module Passporting
  AGE_PASSPORTED_UNTIL = 18.years
  class BasePassporter
    attr_reader :crime_application

    delegate :applicant, :ioj, :resubmission?, to: :crime_application

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

    def age_passported_at_datestamp_or_now?
      return false unless applicant&.date_of_birth

      applicant.date_of_birth.to_date > birth_date_threshold
    end

    def birth_date_threshold
      (crime_application.date_stamp || Time.zone.now).in_time_zone('London').to_date - AGE_PASSPORTED_UNTIL
    end
  end
end
