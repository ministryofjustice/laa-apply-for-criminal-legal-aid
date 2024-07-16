require 'rails_helper'

RSpec.describe Steps::Client::AppealReferenceNumberController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::AppealReferenceNumberForm, Decisions::ClientDecisionTree

  it_behaves_like 'a step disallowed for change in financial circumstances applications'
end
