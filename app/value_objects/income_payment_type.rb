class IncomePaymentType < ValueObject
  VALUES = [
    MAINTAINANCE = new(:maintainance),
    PRIVATE_PENSION = new(:private_pension),
    STATE_PENSION = new(:state_pension),
    INTEREST_INVESTMENT = new(:interest_investment),
    STUDENT_LOAN_GRANT = new(:student_loan_grant),
    BOARD = new(:board),
    RENT = new(:rent),
    FINANCIAL_SUPPORT_WITH_ACCESS = new(:financial_support_with_access),
    FROM_FRIENDS_RELATIVES = new(:from_friends_relatives),
    OTHER = new(:other),
    NONE = new(:none)
  ].freeze
end
