class IncomeBenefitType < ValueObject
  VALUES = [
    MAINTENANCE = new(:child_benefit),
    PRIVATE_PENSION = new(:working_or_child_tax_credit),
    STATE_PENSION = new(:incapacity_benefit),
    INTEREST_INVESTMENT = new(:interest_investment),
    STUDENT_LOAN_GRANT = new(:student_loan_grant),
    BOARD = new(:board_from_family),
    RENT = new(:rent),
    FINANCIAL_SUPPORT_WITH_ACCESS = new(:financial_support_with_access),
    FROM_FRIENDS_RELATIVES = new(:from_friends_relatives),
    OTHER = new(:other),
    NONE = new(:none)
  ].freeze
end


IncomeBenefitType = String.enum(*%w[
  child_benefit
  working_or_child_tax_credit
  incapacity
  industrial_injuries_disablement
  jsa
  other
])
