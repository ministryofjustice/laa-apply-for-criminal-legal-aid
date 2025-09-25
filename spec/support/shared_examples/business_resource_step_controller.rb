require 'rails_helper'

RSpec.shared_examples 'a business resource step controller' do |form_class|
  include_context 'current provider with active office'

  let(:crime_application) do
    CrimeApplication.create(
      office_code: office_code,
      applicant: Applicant.new,
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      businesses: [
        Business.new(business_type: 'partnership', ownership_type: 'applicant'),
        Business.new(business_type: 'self_employed', ownership_type: 'partner')
      ]
    )
  end

  let(:business) { crime_application.businesses.where(ownership_type: subject_type.to_s).first }
  let(:existing_case) { crime_application }

  context 'when subject is client' do
    let(:subject_type) { SubjectType::APPLICANT }

    it_behaves_like 'a generic step controller', form_class, Decisions::SelfEmployedIncomeDecisionTree do
      let(:base_params) { { business_id: business.id, subject: subject_type } }
    end

    context 'when the business is for the partner' do
      let(:business) { crime_application.businesses.where(ownership_type: 'partner').first }

      it 'redirects to the not found error page' do
        get :edit, params: { id: crime_application.id, business_id: business.id, subject: subject_type }
        expect(response).to redirect_to(not_found_errors_path)
      end
    end
  end

  context 'when subject is partner' do
    let(:subject_type) { SubjectType::PARTNER }

    it_behaves_like 'a generic step controller', form_class, Decisions::SelfEmployedIncomeDecisionTree do
      let(:base_params) { { business_id: business.id, subject: subject_type } }
    end
  end
end
