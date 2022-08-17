require 'rails_helper'

RSpec.describe CrimeApplicationsController, type: :controller do

  describe '#index' do
    let(:applications) { CrimeApplication.all } 

    it 'creates @applications' do
      get :index
      expect(@controller.instance_variable_get(:@applications)).to match(applications)
    end
  end

end
