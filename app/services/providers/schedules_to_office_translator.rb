module Providers
  class SchedulesToOfficeTranslator
    def initialize(office_schedules:)
      @office_schedules = office_schedules
    end

    class << self
      def translate(office_schedules)
        new(office_schedules:).translate
      end
    end

    def translate
      Office.new(
        active?: active?,
        contingent_liability?: contingent_liability?,
        name: name,
        office_code: office_code
      )
    end

    private

    delegate :office, :schedules, to: :@office_schedules

    def office_code
      office.firmOfficeCode
    end

    def name
      office.officeName
    end

    def active?
      return true if public_defender_service?
      return false unless crime_schedule

      crime_schedule.scheduleLines.any? do |sl|
        sl.areaOfLaw == crime_lower && sl.categoryOfLaw == ProviderDataApi::Types::CategoryOfLaw['INVEST']
      end
    end

    def public_defender_service?
      @office_schedules.pds
    end

    def contingent_liability?
      return false unless crime_schedule

      crime_schedule.scheduleType == ProviderDataApi::Types::Schedule['Contingent Liability']
    end

    def crime_schedule
      schedules.find { |s| s.areaOfLaw == crime_lower }
    end

    def crime_lower
      ProviderDataApi::Types::AreaOfLaw['CRIME LOWER']
    end
  end
end
