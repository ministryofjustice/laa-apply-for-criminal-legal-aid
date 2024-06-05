require 'rails_helper'

RSpec.describe Steps::DWP::HasBenefitEvidencePartnerForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: partner_record,
    }.merge(
      form_attributes
    )
  end

  let(:form_attributes) do
    { has_benefit_evidence: }
  end

  let(:crime_application) { instance_double(CrimeApplication, partner: partner_record) }
  let(:partner_record) { Partner.new }
  let(:has_benefit_evidence) { 'yes' }

  describe '#save' do
    context 'when form is valid' do
      it 'saves the record' do
        expect(partner_record).to receive(:update).with(
          { 'has_benefit_evidence' => YesNoAnswer::YES }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
