require 'rails_helper'

RSpec.describe Steps::Outgoings::MiscPaymentsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Outgoings::MiscPaymentsForm, Decisions::OutgoingsDecisionTree do
    describe 'CRUD actions' do
      let(:crime_application) { CrimeApplication.create }

      context 'finishing misc payments' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Outgoings::MiscPaymentsForm, as: :misc_payments
          )

          put :update, params: { id: crime_application }
        end
      end
    end
  end
end
