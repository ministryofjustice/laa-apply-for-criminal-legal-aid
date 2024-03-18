require 'rails_helper'

RSpec.describe Steps::Capital::ResidentialPropertyController, type: :controller do
  include_examples 'property controller', 'residential'
end
