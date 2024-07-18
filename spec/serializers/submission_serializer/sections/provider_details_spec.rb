require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ProviderDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      office_code: 'XYZ',
      provider_email: 'foo@bar.com',
      legal_rep_has_partner_declaration: rep_has_partner_declaration,
      legal_rep_no_partner_declaration_reason: rep_no_declaration_reason,
      legal_rep_first_name: 'John',
      legal_rep_last_name: 'Doe',
      legal_rep_telephone: '123456789',
    )
  end

  let(:rep_has_partner_declaration) { nil }
  let(:rep_no_declaration_reason) { nil }

  let(:json_output) do
    {
      provider_details: {
        office_code: 'XYZ',
        provider_email: 'foo@bar.com',
        legal_rep_has_partner_declaration: nil,
        legal_rep_no_partner_declaration_reason: nil,
        legal_rep_first_name: 'John',
        legal_rep_last_name: 'Doe',
        legal_rep_telephone: '123456789',
      }
    }.as_json
  end

  let(:json_with_partner_output) do
    {
      provider_details: {
        office_code: 'XYZ',
        provider_email: 'foo@bar.com',
        legal_rep_has_partner_declaration: 'no',
        legal_rep_no_partner_declaration_reason: 'A reason',
        legal_rep_first_name: 'John',
        legal_rep_last_name: 'Doe',
        legal_rep_telephone: '123456789',
      }
    }.as_json
  end

  describe '#generate' do
    context 'when there is no partner' do
      it { expect(subject.generate).to eq(json_output) }
    end

    context 'when there is a partner' do
      let(:rep_has_partner_declaration) { 'no' }
      let(:rep_no_declaration_reason) { 'A reason' }

      it { expect(subject.generate).to eq(json_with_partner_output) }
    end
  end
end
