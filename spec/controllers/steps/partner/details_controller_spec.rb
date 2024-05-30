require 'rails_helper'

RSpec.describe Steps::Partner::DetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Partner::DetailsForm, Decisions::PartnerDecisionTree
end
