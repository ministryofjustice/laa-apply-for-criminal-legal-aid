require 'rails_helper'

RSpec.describe Steps::Submission::DeclarationController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Submission::DeclarationForm, Decisions::SubmissionDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Submission::DeclarationForm
end
