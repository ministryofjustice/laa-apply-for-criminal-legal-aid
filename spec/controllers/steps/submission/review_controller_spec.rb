require 'rails_helper'

RSpec.describe Steps::Submission::ReviewController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Submission::ReviewForm, Decisions::SubmissionDecisionTree
end
