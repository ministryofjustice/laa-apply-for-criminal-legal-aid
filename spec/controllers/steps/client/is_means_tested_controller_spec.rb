require 'rails_helper'

RSpec.describe Steps::Client::IsMeansTestedController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::IsMeansTestedForm, Decisions::ClientDecisionTree
end
