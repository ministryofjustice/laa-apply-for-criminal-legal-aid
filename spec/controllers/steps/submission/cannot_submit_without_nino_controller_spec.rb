require 'rails_helper'

RSpec.describe Steps::Submission::CannotSubmitWithoutNinoController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Submission::CannotSubmitWithoutNinoForm,
                  Decisions::SubmissionDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Submission::CannotSubmitWithoutNinoForm
end
