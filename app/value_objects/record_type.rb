class RecordType < ValueObject
  VALUES = [
    APPLICATION = new(:application),
    USER = new(:user),
  ].freeze
end
