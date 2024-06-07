require 'rails_helper'

RSpec.describe PartnerDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record: partner_detail) }

  # Fully complete partner_detail
  let(:partner_detail) do
    PartnerDetail.new(
      crime_application: crime_application,
      relationship_status: nil,
      separation_date: nil,
      relationship_to_partner: 'married_or_partnership',
      involvement_in_case: 'none',
      conflict_of_interest: 'no',
      has_same_address_as_client: 'no',
    )
  end

  let(:crime_application) { CrimeApplication.new(client_has_partner:, partner:) }

  let(:partner) do
    Partner.new(
      first_name: 'Jimmy',
      last_name: 'Mack',
      other_names: nil,
      date_of_birth: Date.new(1977, 3, 15),
      nino: 'JA293483A',
      has_nino: 'yes',
    )
  end

  let(:home_address) { instance_double(Address, type: 'HomeAddress', person: partner, postcode: 'SW1A 2AA') }
  let(:client_has_partner) { nil }

  before do
    allow(partner).to receive(:home_address).and_return(home_address)
  end

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when client has partner' do
      let(:client_has_partner) { 'yes' }

      it { is_expected.to be true }
    end

    context 'when client does not have partner' do
      let(:client_has_partner) { 'no' }

      it { is_expected.to be false }
    end
  end

  describe '#complete?' do
    subject(:complete?) do
      described_class.new(record: nil, crime_application: crime_application).complete?
    end

    context 'with nil record' do
      it { is_expected.to be false }

      it 'does not bother checking if there is a partner' do
        expect(crime_application).not_to receive(:client_has_partner)
      end
    end

    context 'without a partner' do
      subject(:complete?) { validator.complete? }

      let(:client_has_partner) { 'no' }

      context 'with a relationship status' do
        before { partner_detail.relationship_status = 'divorced' }

        it { is_expected.to be true }
      end

      context 'without a relationship status' do
        before { partner_detail.relationship_status = nil }

        it { is_expected.to be false }
      end
    end

    # NOTE: Relies on top level partner_detail to be valid
    context 'with a partner' do
      subject(:complete?) { validator.complete? }

      let(:client_has_partner) { 'yes' }

      context 'with partner and all conditions met' do
        it { is_expected.to be true }
      end

      context 'without address when living apart' do
        before { partner_detail.has_same_address_as_client = 'no' }

        let(:home_address) { nil }

        it { is_expected.to be false }
      end

      context 'without address when living together' do
        before { partner_detail.has_same_address_as_client = 'yes' }

        let(:home_address) { nil }

        it { is_expected.to be true }
      end

      context 'without relationship to partner' do
        before { partner_detail.relationship_to_partner = nil }

        it { is_expected.to be false }
      end

      context 'without involvement in case' do
        before { partner_detail.involvement_in_case = nil }

        it { is_expected.to be false }
      end

      context 'without nino' do
        before { partner.has_nino = 'no' }

        it { is_expected.to be true }
      end

      context 'with nino but without nino value' do
        before do
          partner.has_nino = 'yes'
          partner.nino = nil
        end

        it { is_expected.to be false }
      end

      context 'when partner has a conflict of interest' do
        before do
          partner_detail.involvement_in_case = 'codefendant'
          partner_detail.conflict_of_interest = 'yes'
        end

        it { is_expected.to be true }
      end
    end
  end

  describe '#validate' do
    let(:client_has_partner) { 'yes' }

    context 'when not complete' do
      before { partner_detail.involvement_in_case = nil }

      it 'adds errors' do
        subject.validate

        expect(subject.errors.of_kind?('partner_details', :incomplete)).to be(true)
      end
    end
  end
end
