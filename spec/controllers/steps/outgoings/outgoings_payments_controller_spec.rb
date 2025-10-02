require 'rails_helper'

RSpec.describe Steps::Outgoings::OutgoingsPaymentsController, type: :controller do
  # rubocop:disable Layout/LineLength
  it_behaves_like 'a generic step controller', Steps::Outgoings::OutgoingsPaymentsForm, Decisions::OutgoingsDecisionTree do
    describe 'CRUD actions' do
      let(:crime_application) { CrimeApplication.create office_code: }

      context 'finishing outgoings payments' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Outgoings::OutgoingsPaymentsForm, as: :outgoings_payments
          )

          put :update, params: { id: crime_application }
        end
      end
    end
  end
  # rubocop:enable Layout/LineLength
end
