module ProviderDataApi
  class RecordNotFound < StandardError; end

  module Types
    include Dry.Types()

    AreaOfLaw = String.enum(
      'MEDIATION',
      'LEGAL HELP',
      'CIVIL FUNDING',
      'CRIME LOWER'
    )

    CategoryOfLaw = String.enum(*%w[
      AAP
      ALL
      APPEALS
      CLA
      COM
      CON
      DEB
      DISC
      EDU
      ELA
      EMP
      HOU
      IMMAS
      IMMOT
      INVEST
      MAT
      MED
      MHE
      MSC
      PI
      PRISON
      PUB
      WB
    ])

    Schedule = String.enum(
      'Individual Case Contract',
      'CLA',
      'Standard',
      'Contingent Liability'
    )
  end

  class ScheduleLines < Dry::Struct
    transform_keys(&:to_sym)

    attribute :areaOfLaw, Types::AreaOfLaw
    attribute :categoryOfLaw, Types::CategoryOfLaw
  end

  class Schedule < Dry::Struct
    transform_keys(&:to_sym)

    attribute :scheduleType, Types::Schedule
    attribute :areaOfLaw, Types::AreaOfLaw
    attribute :scheduleLines, Types::Array.of(ScheduleLines)
  end

  class Office < Dry::Struct
    transform_keys(&:to_sym)

    attribute :officeName, Types::String
    attribute :firmOfficeCode, Types::String
  end

  class OfficeSchedules < Dry::Struct
    transform_keys(&:to_sym)

    attribute :office, Office
    attribute :schedules, Types::Array.of(Schedule)
    attribute :pds, Types::Bool
  end
end
