require 'rails_helper'

RSpec.describe Steps::Capital::ResidentialPropertyController, type: :controller do
  it_behaves_like 'capital properties controller', 'residential'
end
