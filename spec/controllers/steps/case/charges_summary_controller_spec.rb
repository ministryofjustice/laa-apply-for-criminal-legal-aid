require 'rails_helper'

RSpec.describe Steps::Case::ChargesSummaryController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::ChargesSummaryForm, Decisions::CaseDecisionTree
end
