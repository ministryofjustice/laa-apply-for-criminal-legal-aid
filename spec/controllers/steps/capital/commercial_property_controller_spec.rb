require 'rails_helper'

RSpec.describe Steps::Capital::CommercialPropertyController, type: :controller do
  it_behaves_like 'capital properties controller', 'commercial'
end
