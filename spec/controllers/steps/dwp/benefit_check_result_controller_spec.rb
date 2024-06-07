require 'rails_helper'

RSpec.describe Steps::DWP::BenefitCheckResultController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::BenefitCheckResultForm, Decisions::DWPDecisionTree
end
