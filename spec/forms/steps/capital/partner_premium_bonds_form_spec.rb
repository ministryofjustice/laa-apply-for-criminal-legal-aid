require 'rails_helper'

RSpec.describe Steps::Capital::PartnerPremiumBondsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: capital,
    }.merge(attributes)
  end

  let(:attributes) { {} }

  let(:capital) { instance_double(Capital) }

  let(:crime_application) do
    instance_double(CrimeApplication, capital:)
  end

  describe 'validations' do
    it { is_expected.to validate_is_a(:partner_has_premium_bonds, YesNoAnswer) }

    context 'when `partner_has_premium_bonds` answered yes' do
      before { form.partner_has_premium_bonds = 'yes' }

      it { is_expected.to validate_presence_of(:partner_premium_bonds_total_value) }
      it { is_expected.to validate_presence_of(:partner_premium_bonds_holder_number) }
    end

    context 'when `partner_has_premium_bonds` answered no' do
      before { form.partner_has_premium_bonds = 'no' }

      it { is_expected.not_to validate_presence_of(:partner_premium_bonds_total_value) }
      it { is_expected.not_to validate_presence_of(:partner_premium_bonds_holder_number) }
    end
  end

  describe '#save' do
    context 'for valid details' do
      before do
        allow(capital).to receive(:update).and_return(true)

        form.partner_has_premium_bonds = partner_has_premium_bonds
        form.partner_premium_bonds_total_value = '100023.00'
        form.partner_premium_bonds_holder_number = '123568A'

        subject.save
      end

      context 'when `partner_has_premium_bonds` answered yes' do
        let(:partner_has_premium_bonds) { 'yes' }

        let(:expected_args) do
          {
            partner_has_premium_bonds: YesNoAnswer::YES,
            partner_premium_bonds_total_value: Money.new(10_002_300),
            partner_premium_bonds_holder_number: '123568A'
          }
        end

        it 'updates capital with partner premium bond details' do
          expect(capital).to have_received(:update).with(expected_args.stringify_keys)
        end
      end

      context 'when partner_has premium bonds answered no' do
        let(:partner_has_premium_bonds) { 'no' }

        let(:expected_args) do
          {
            partner_has_premium_bonds: YesNoAnswer::NO,
            partner_premium_bonds_total_value: nil,
            partner_premium_bonds_holder_number: nil
          }.stringify_keys
        end

        it 'updates the record and sets the detail attributes to nil' do
          expect(capital).to have_received(:update).with(expected_args)
        end
      end
    end
  end
end
