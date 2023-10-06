require 'rails_helper'

RSpec.describe Steps::Client::HasBenefitEvidenceController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::HasBenefitEvidenceForm, Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::HasBenefitEvidenceForm
end
