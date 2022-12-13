require 'rails_helper'

RSpec.describe Steps::Submission::FailureController, type: :controller do
  it_behaves_like 'a no-op advance step controller', :submission_retry, Decisions::SubmissionDecisionTree
end
