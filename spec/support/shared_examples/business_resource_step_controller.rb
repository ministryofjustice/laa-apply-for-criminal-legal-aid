require 'rails_helper'

RSpec.shared_examples 'a business resource step controller' do |form_class|
  let(:crime_application) do
    CrimeApplication.create(
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
  end

  context 'when subject is partner' do
    let(:subject_type) { SubjectType::PARTNER }

    it_behaves_like 'a generic step controller', form_class, Decisions::SelfEmployedIncomeDecisionTree do
      let(:base_params) { { business_id: business.id, subject: subject_type } }
    end
  end
end
