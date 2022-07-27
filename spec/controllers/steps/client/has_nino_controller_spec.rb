require 'rails_helper'

RSpec.describe Steps::Client::HasNinoController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Client::HasNinoForm, Decisions::ClientDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Client::HasNinoForm
end
