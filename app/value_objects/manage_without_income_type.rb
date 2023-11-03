class ManageWithoutIncomeType < ValueObject
  VALUES = [
    FRIENDS_SOFA = new(:friends_sofa),
    FAMILY = new(:family),
    HOMELESS = new(:homeless),
    CUSTODY = new(:custody),
    OTHER = new(:other),
  ].freeze
end
