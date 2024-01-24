require 'rails_helper'

RSpec.describe Steps::Client::DateStampController, type: :controller do
  it_behaves_like 'a no-op advance step controller', :date_stamp, Decisions::ClientDecisionTree
end
