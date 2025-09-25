require 'rails_helper'

RSpec.describe Steps::DWP::PartnerConfirmResultController, type: :controller do
  include_context 'current provider with active office'
  it_behaves_like 'a generic step controller', Steps::DWP::PartnerConfirmResultForm, Decisions::DWPDecisionTree
end
