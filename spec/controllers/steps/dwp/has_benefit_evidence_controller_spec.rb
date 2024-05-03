require 'rails_helper'

RSpec.describe Steps::DWP::HasBenefitEvidenceController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::HasBenefitEvidenceForm, Decisions::DWPDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::DWP::HasBenefitEvidenceForm
end
