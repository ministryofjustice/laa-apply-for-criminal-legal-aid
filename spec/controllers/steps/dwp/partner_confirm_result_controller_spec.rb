require 'rails_helper'

RSpec.describe Steps::DWP::PartnerConfirmResultController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DWP::PartnerConfirmResultForm, Decisions::DWPDecisionTree
end
