class EmploymentStatus < ValueObject
  VALUES = [
    EMPLOYED = new(:employed),
    SELF_EMPLOYED = new(:self_employed),
    BUSINESS_PARTNERSHIP = new(:business_partnership),
    DIRECTOR = new(:director),
    SHAREHOLDER = new(:shareholder),
    NOT_WORKING = new(:not_working),
  ].freeze
end