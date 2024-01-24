class HousingPaymentType < ValueObject
  VALUES = [
    RENT = new(:rent),
    MORTGAGE = new(:mortgage),
    BOARD_LODGINGS = new(:board_lodgings),
    NONE = new(:none),
  ].freeze
end
