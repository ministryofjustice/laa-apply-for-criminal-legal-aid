class FirstHearingAnswer < ValueObject
  VALUES = [
    YES = new(:yes),
    NO = new(:no),
    NO_HEARING_YET = new(:no_hearing_yet)
  ].freeze
end
