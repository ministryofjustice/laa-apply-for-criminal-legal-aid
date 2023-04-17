class IojPassportType < ValueObject
  VALUES = [
    ON_AGE_UNDER18 = new(:on_age_under18),
    ON_OFFENCE = new(:on_offence),
  ].freeze
end
