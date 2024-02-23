class HouseType < ValueObject
  VALUES = [
    BUNGALOW = new(:bungalow),
    DETACHED = new(:detached),
    FLAT_OR_MAISONETTE = new(:flat_or_maisonette),
    SEMIDETACHED = new(:semidetached),
    TERRACED = new(:terraced),
  ].freeze
end
