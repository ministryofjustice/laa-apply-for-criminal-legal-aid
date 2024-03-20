require 'rails_helper'

RSpec.describe Steps::Capital::LandController, type: :controller do
  include_examples 'capital properties controller', 'land'
end
