require 'rails_helper'

RSpec.describe Steps::Submission::ReviewController, type: :controller do
  it_behaves_like 'a no-op advance step controller', :review, Decisions::SubmissionDecisionTree
end
