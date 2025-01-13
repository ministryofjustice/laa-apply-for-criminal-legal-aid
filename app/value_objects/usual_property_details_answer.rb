class UsualPropertyDetailsAnswer < ValueObject
  VALUES = [
    PROVIDE_DETAILS = new(:provide_details),
    CHANGE_ANSWER = new(:change_answer)
  ].freeze
end
