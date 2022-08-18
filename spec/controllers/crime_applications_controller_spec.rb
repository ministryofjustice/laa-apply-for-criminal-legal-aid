require 'rails_helper'

RSpec.describe CrimeApplicationsController, type: :controller do
  describe '#edit' do
    before do
      allow(CrimeApplication).to receive(:find).with('12345').and_return(crime_application)
    end

    let(:crime_application) { instance_double(CrimeApplication) }

    it 'initialises the task list' do
      get :edit, params: { id: '12345' }
      expect(controller.instance_variable_get(:@tasklist)).to be_a(TaskList::Collection)
    end
  end
end
