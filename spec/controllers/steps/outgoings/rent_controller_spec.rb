require 'rails_helper'

RSpec.describe Steps::Outgoings::RentController, type: :controller do
  let(:existing_case) do
    CrimeApplication.create(
      applicant: Applicant.new,
      outgoings: Outgoings.new(housing_payment_type: 'rent')
    )
  end

  it_behaves_like 'a generic step controller', Steps::Outgoings::RentForm, Decisions::OutgoingsDecisionTree do
    describe 'CRUD actions' do
      let(:crime_application) { CrimeApplication.create }

      context 'finishing rent' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Outgoings::RentForm, as: :rent
          )

          put :update, params: { id: crime_application }
        end
      end
    end
  end

  context 'when not editable?' do
    let(:crime_application) { CrimeApplication.create }

    it 'redirects to the application not found error page' do
      get :edit, params: { id: crime_application }
      expect(response).to redirect_to(edit_steps_outgoings_housing_payment_type_path)
    end
  end
end
