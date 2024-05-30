require 'rails_helper'

RSpec.describe Steps::Partner::NinoController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Partner::NinoForm, Decisions::PartnerDecisionTree
end
