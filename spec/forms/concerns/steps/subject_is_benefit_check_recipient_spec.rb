require 'rails_helper'

RSpec.describe Steps::SubjectIsBenefitCheckRecipient do
  subject(:assessable) do
    assessable_class.new(crime_application:)
  end

  let(:assessable_class) do
    Struct.new(:crime_application) do
      include Steps::SubjectIsBenefitCheckRecipient
    end
  end

  let(:crime_application) do
    instance_double(CrimeApplication, partner:)
  end

  let(:partner) { instance_double(Partner, has_passporting_benefit?: has_passporting_benefit) }
  let(:has_passporting_benefit) { true }

  describe '#subject' do
    context 'when partner has passporting benefit' do
      it 'returns partner subject' do
        expect(assessable.subject).to eq 'the partner'
      end
    end

    context 'when partner does not have passporting benefit' do
      let(:has_passporting_benefit) { false }

      it 'returns applicant subject' do
        expect(assessable.subject).to eq 'your client'
      end
    end
  end

  describe '#form_subject' do
    subject(:form_subject) { assessable.form_subject }

    context 'when partner has passporting benefit' do
      it { is_expected.to eq SubjectType::PARTNER }
    end

    context 'when partner does not have passporting benefit' do
      let(:has_passporting_benefit) { false }

      it { is_expected.to eq SubjectType::APPLICANT }
    end
  end
end
