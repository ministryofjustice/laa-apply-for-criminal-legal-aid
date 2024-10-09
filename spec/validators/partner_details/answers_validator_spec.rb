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
      has_partner: has_partner,
    )
  end

  let(:crime_application) { CrimeApplication.new(partner:) }

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

  let(:home_address) do
    instance_double(Address, type: 'HomeAddress', person: partner,
                                       address_line_one: 'Test Address Line 1')
  end
  let(:has_partner) { nil }

  before do
    allow(partner).to receive(:home_address).and_return(home_address)
  end

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when client has partner' do
      let(:has_partner) { 'yes' }

      it { is_expected.to be true }
    end

    context 'when client does not have partner' do
      let(:has_partner) { 'no' }

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
        expect(partner_detail).not_to receive(:has_partner)
      end
    end

    # NOTE: Relies on top level partner_detail to be valid
    context 'with a partner' do
      subject(:complete?) { validator.complete? }

      let(:has_partner) { 'yes' }

      context 'with partner and all conditions met' do
        it { is_expected.to be true }
      end

      context 'when living apart' do
        before { partner_detail.has_same_address_as_client = 'no' }

        context 'without address' do
          let(:home_address) { nil }

          it { is_expected.to be false }
        end

        context 'when partner address incomplete' do
          let(:home_address) { instance_double(Address, type: 'HomeAddress', person: partner, address_line_one: nil) }

          it { is_expected.to be false }
        end
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

      context 'with arc but without arc value' do
        before do
          partner.has_nino = 'arc'
          partner.nino = nil
          partner.arc = nil
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
    let(:has_partner) { 'yes' }

    context 'when not complete' do
      before { partner_detail.involvement_in_case = nil }

      it 'adds errors' do
        subject.validate

        expect(subject.errors.of_kind?('involvement_in_case', :incomplete)).to be(true)
        expect(subject.errors.of_kind?('base', :incomplete_records)).to be(true)
      end
    end
  end
end
