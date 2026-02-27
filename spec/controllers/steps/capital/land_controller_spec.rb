require 'rails_helper'

RSpec.describe Steps::Capital::LandController, type: :controller do
  it_behaves_like 'capital properties controller', 'land'
end
