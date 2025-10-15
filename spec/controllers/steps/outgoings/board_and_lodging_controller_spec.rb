require 'rails_helper'

RSpec.describe Steps::Outgoings::BoardAndLodgingController, type: :controller do
  include_context 'current provider with active office'

  let(:existing_case) do
    CrimeApplication.create(
      office_code: office_code,
      applicant: Applicant.new,
      outgoings: Outgoings.new(housing_payment_type: 'board_and_lodging')
    )
  end

  it_behaves_like 'a generic step controller', Steps::Outgoings::BoardAndLodgingForm,
                  Decisions::OutgoingsDecisionTree do
    describe 'CRUD actions' do
      let(:crime_application) { CrimeApplication.create(office_code:) }

      context 'finishing board_and_lodging' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Outgoings::BoardAndLodgingForm, as: :board_and_lodging
          )

          put :update, params: { id: crime_application }
        end
      end
    end
  end

  context 'when not editable?' do
    let(:crime_application) { CrimeApplication.create(office_code:) }

    it 'redirects to the application not found error page' do
      get :edit, params: { id: crime_application }
      expect(response).to redirect_to(edit_steps_outgoings_housing_payment_type_path)
    end
  end
end
