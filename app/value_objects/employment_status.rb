class EmploymentStatus < ValueObject
  VALUES = [
    EMPLOYED = new(:employed),
    SELF_EMPLOYED = new(:self_employed),
    NOT_WORKING = new(:not_working),
  ].freeze
end
