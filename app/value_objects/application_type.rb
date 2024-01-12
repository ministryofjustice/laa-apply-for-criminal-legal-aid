class ApplicationType < ValueObject
  VALUES = [
    INITIAL = new(:initial),
    POST_SUBMISSION_EVIDENCE = new(:post_submission_evidence)
  ].freeze
end
