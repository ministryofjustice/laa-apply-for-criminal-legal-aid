require 'rails_helper'

RSpec.describe Steps::ApplicantOrPartnerExclusive do
  subject(:assessable) do
    assessable_class.new(crime_application:)
  end

  let(:assessable_class) do
    Struct.new(:crime_application) do
      include Steps::ApplicantOrPartnerExclusive
    end
  end

  let(:crime_application) do
    instance_double(CrimeApplication, partner:)
  end

  let(:partner) { instance_double(Partner, has_passporting_benefit?: has_passporting_benefit) }
  let(:has_passporting_benefit) { true }

  describe '#subject' do
    subject(:subject) { assessable.subject }

    context 'when partner has passporting benefit' do
      it { is_expected.to eq 'the partner' }
    end

    context 'when partner does not have passporting benefit' do
      let(:has_passporting_benefit) { false }

      it { is_expected.to eq 'your client' }
    end
  end

  describe '#subject_ownership_type' do
    subject(:subject_ownership_type) { assessable.subject_ownership_type }

    context 'when partner has passporting benefit' do
      it { is_expected.to eq OwnershipType::PARTNER.to_s }
    end

    context 'when partner does not have passporting benefit' do
      let(:has_passporting_benefit) { false }

      it { is_expected.to eq OwnershipType::APPLICANT.to_s }
    end
  end
end
