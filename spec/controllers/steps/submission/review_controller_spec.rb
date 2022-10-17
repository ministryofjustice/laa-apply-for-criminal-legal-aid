require 'rails_helper'

RSpec.describe Steps::Submission::ReviewController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Submission::ReviewForm, Decisions::SubmissionDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Submission::ReviewForm
end
