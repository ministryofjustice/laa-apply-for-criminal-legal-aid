class MeansPassportType < ValueObject
  VALUES = [
    ON_NOT_MEANS_TESTED = new(:on_not_means_tested),
    ON_AGE_UNDER18 = new(:on_age_under18),
    ON_BENEFIT_CHECK = new(:on_benefit_check),
  ].freeze
end
