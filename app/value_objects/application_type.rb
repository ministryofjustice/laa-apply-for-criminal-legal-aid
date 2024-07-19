class ApplicationType < ValueObject
  VALUES = [
    INITIAL = new(:initial),
    POST_SUBMISSION_EVIDENCE = new(:post_submission_evidence),
    CHANGE_IN_FINANCIAL_CIRCUMSTANCES = new(:change_in_financial_circumstances),
  ].freeze
end
