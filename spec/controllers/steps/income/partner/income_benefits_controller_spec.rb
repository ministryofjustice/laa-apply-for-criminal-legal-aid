require 'rails_helper'

RSpec.describe Steps::Income::Partner::IncomeBenefitsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::Partner::IncomeBenefitsForm,
                  Decisions::IncomeDecisionTree do
    describe 'CRUD actions' do
      let(:crime_application) { CrimeApplication.create }

      context 'finishing income benefits' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Income::Partner::IncomeBenefitsForm, as: :partner_income_benefits
          )

          put :update, params: { id: crime_application }
        end
      end
    end
  end
end
