class YesNoAnswer < ValueObject
  VALUES = [
    YES = new(:yes),
    NO  = new(:no)
  ].freeze
end
