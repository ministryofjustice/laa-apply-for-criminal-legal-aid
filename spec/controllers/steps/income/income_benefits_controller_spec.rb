require 'rails_helper'

RSpec.describe Steps::Income::IncomeBenefitsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::IncomeBenefitsForm, Decisions::IncomeDecisionTree do
    describe 'CRUD actions' do
      let(:crime_application) { CrimeApplication.create(office_code:) }

      context 'finishing income benefits' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Income::IncomeBenefitsForm, as: :income_benefits
          )

          put :update, params: { id: crime_application }
        end
      end
    end
  end
end
