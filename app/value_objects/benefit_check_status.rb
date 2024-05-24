class BenefitCheckStatus < ValueObject
  VALUES = [
    NO_CHECK_NO_NINO = new(:no_check_no_nino),
    UNDETERMINED = new(:undetermined),
    NO_RECORD_FOUND = new(:no_record_found),
    NO_CHECK_REQUIRED = new(:no_check_required),
    CHECKER_UNAVAILABLE = new(:checker_unavailable),
    CONFIRMED = new(:confirmed),
  ].freeze
end
