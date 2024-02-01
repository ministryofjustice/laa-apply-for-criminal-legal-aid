require 'rails_helper'

RSpec.describe Steps::Case::IsPreorderWorkClaimedController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Case::IsPreorderWorkClaimedForm, Decisions::CaseDecisionTree
end
