class IncomePaymentType < ValueObject
  VALUES = [
    MAINTENANCE = new(:maintenance),
    PRIVATE_PENSION = new(:private_pension),
    STATE_PENSION = new(:state_pension),
    INTEREST_INVESTMENT = new(:interest_investment),
    STUDENT_LOAN_GRANT = new(:student_loan_grant),
    BOARD = new(:board_from_family),
    RENT = new(:rent),
    FINANCIAL_SUPPORT_WITH_ACCESS = new(:financial_support_with_access),
    FROM_FRIENDS_RELATIVES = new(:from_friends_relatives),
    OTHER = new(:other)
  ].freeze
end
