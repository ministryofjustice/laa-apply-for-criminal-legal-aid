require 'rails_helper'

RSpec.describe Steps::Submission::MoreInformationController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Submission::MoreInformationForm,
                  Decisions::SubmissionDecisionTree
end
