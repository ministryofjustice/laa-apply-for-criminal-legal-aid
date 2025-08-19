class RecordType < ValueObject
  VALUES = [
    APPLICATION = new(:application),
    DOCUMENT = new(:document),
    USER = new(:user),
  ].freeze
end
