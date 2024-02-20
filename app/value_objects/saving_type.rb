class SavingType < ValueObject
  VALUES = [
    BANK = new(:bank),
    BUILDING_SOCIETY = new(:building_society),
    CASH_ISA = new(:cash_isa),
    NATIONAL_SAVINGS_OR_POST_OFFICE = new(:national_savings_or_post_office),
    OTHER = new(:other),
  ].freeze
end
