require 'rails_helper'

RSpec.describe Steps::Income::BusinessesSummaryController, type: :controller do
  let(:existing_case) do
    CrimeApplication.create(
      businesses: businesses,
      applicant: Applicant.new,
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involved_in_case: 'no', involvement_in_case: nil)
    )
  end

  context 'when businesses present' do
    let(:businesses) {
      [
        Business.new(business_type: 'partnership', ownership_type: 'applicant'),
        Business.new(business_type: 'self_employed', ownership_type: 'partner')
      ]
    }

    context 'when subject is client' do
      it_behaves_like 'a generic step controller',
                      Steps::Income::BusinessesSummaryForm, Decisions::SelfEmployedIncomeDecisionTree do
                        let(:base_params) { { subject: 'client' } }
                      end
    end

    context 'when subject is partner' do
      it_behaves_like 'a generic step controller',
                      Steps::Income::BusinessesSummaryForm, Decisions::SelfEmployedIncomeDecisionTree do
                        let(:base_params) { { subject: 'partner' } }
                      end
    end
  end

  context 'when businesses empty' do
    let(:businesses) { [] }

    describe '#edit' do
      it 'redirects to the businesses type page' do
        get :edit, params: { id: existing_case, subject: 'client' }

        expect(response).to redirect_to(
          edit_steps_income_business_type_path(existing_case, 'client')
        )
      end
    end
  end
end
