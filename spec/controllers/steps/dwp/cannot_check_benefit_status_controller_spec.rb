require 'rails_helper'

RSpec.describe Steps::DWP::CannotCheckBenefitStatusController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::CannotCheckBenefitStatusForm,
                  Decisions::DWPDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::DWP::CannotCheckBenefitStatusForm
end
