class ManageWithoutIncomeType < ValueObject
  VALUES = [
    FRIENDS_SOFA = new(:friends_sofa),
    FAMILY = new(:family),
    LIVING_ON_STREETS = new(:living_on_streets),
    CUSTODY = new(:custody),
    OTHER = new(:other),
  ].freeze
end
