class MeansPassportType < ValueObject
  VALUES = [
    ON_AGE_UNDER18 = new(:on_age_under18),
    ON_BENEFIT_CHECK = new(:on_benefit_check),
  ].freeze
end
