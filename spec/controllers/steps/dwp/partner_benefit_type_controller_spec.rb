require 'rails_helper'

RSpec.describe Steps::DWP::PartnerBenefitTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::PartnerBenefitTypeForm, Decisions::DWPDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::DWP::PartnerBenefitTypeForm
end
