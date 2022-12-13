require 'rails_helper'

RSpec.describe Steps::DWP::ConfirmResultController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::ConfirmResultForm, Decisions::DWPDecisionTree
end
