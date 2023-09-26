require 'rails_helper'

RSpec.describe Steps::Client::BenefitTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::BenefitTypeForm, Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::BenefitTypeForm
end
