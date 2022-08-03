require 'rails_helper'

RSpec.describe Steps::Contact::PostcodeLookupController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Contact::PostcodeLookupForm, Decisions::ContactDecisionTree
end
