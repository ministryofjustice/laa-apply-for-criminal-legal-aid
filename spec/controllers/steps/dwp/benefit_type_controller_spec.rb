require 'rails_helper'

RSpec.describe Steps::DWP::BenefitTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::BenefitTypeForm, Decisions::DWPDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::DWP::BenefitTypeForm
end
