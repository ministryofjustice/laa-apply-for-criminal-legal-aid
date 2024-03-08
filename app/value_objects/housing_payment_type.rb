class HousingPaymentType < ValueObject
  VALUES = [
    RENT = new(:rent),
    MORTGAGE = new(:mortgage),
    BOARD_AND_LODGING = new(:board_and_lodging),
    NONE = new(:none),
  ].freeze
end
