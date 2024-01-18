class ApplicationType < ValueObject
  # NOTE: for MVP, all applications are "initial"
  VALUES = [
    INITIAL = new(:initial),
    POST_SUBMISSION_EVIDENCE = new(:post_submission_evidence),
  ].freeze
end
