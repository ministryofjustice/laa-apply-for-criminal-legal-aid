require 'rails_helper'

RSpec.describe Steps::Income::Partner::IncomePaymentsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::Partner::IncomePaymentsForm,
                  Decisions::IncomeDecisionTree do
    describe 'CRUD actions' do
      let(:crime_application) { CrimeApplication.create }

      context 'finishing income payments' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Income::Partner::IncomePaymentsForm, as: :partner_income_payments
          )

          put :update, params: { id: crime_application }
        end
      end
    end
  end
end
