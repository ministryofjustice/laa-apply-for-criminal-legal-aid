class OutgoingsPaymentType < ValueObject
  VALUES = [
    RENT = new(:rent),
    MORTGAGE = new(:mortgage),
    BOARD_AND_LODGING = new(:board_and_lodging),
    COUNCIL_TAX = new(:council_tax),
    CHILDCARE = new(:childcare),
    MAINTENANCE = new(:maintenance),
    LEGAL_AID_CONTRIBUTION = new(:legal_aid_contribution)
  ].freeze

  OTHER_PAYMENT_TYPES = [
    CHILDCARE,
    MAINTENANCE,
    LEGAL_AID_CONTRIBUTION,
  ].freeze

  HOUSING_PAYMENT_TYPES = [
    RENT,
    MORTGAGE,
    BOARD_AND_LODGING,
  ].freeze
end
