require 'rails_helper'

RSpec.describe Steps::Evidence::UploadController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Evidence::UploadForm, Decisions::EvidenceDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::Evidence::UploadForm
end
