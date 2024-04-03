require 'rails_helper'

RSpec.describe Steps::Client::CannotCheckBenefitStatusController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::CannotCheckBenefitStatusForm,
                  Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::CannotCheckBenefitStatusForm
end
