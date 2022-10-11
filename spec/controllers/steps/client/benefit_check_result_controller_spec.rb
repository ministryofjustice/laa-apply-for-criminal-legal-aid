require 'rails_helper'

RSpec.describe Steps::Client::BenefitCheckResultController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::BenefitCheckResultForm, Decisions::ClientDecisionTree
end
