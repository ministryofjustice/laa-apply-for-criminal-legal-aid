class HouseType < ValueObject
  VALUES = [
    BUNGALOW = new(:bungalow),
    DETACHED = new(:detached),
    FLAT = new(:flat),
    SEMIDETACHED = new(:semidetached),
    TERRACED = new(:terraced),
  ].freeze
end
