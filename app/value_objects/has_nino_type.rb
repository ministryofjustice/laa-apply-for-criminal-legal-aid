class HasNinoType < ValueObject
  VALUES = [
    YES = new(:yes),
    NO  = new(:no),
    ARC = new(:arc)
  ].freeze
end
