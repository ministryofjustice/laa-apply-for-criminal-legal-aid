class PropertyType < ValueObject
  VALUES = [
    RESIDENTIAL = new(:residential),
    COMMERCIAL = new(:commercial),
    LAND = new(:land)
  ].freeze
end
