require 'rails_helper'

RSpec.describe Steps::Capital::PremiumBondsForm do
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
    it { is_expected.to validate_is_a(:has_premium_bonds, YesNoAnswer) }

    context 'when has premium bonds answered yes' do
      before { form.has_premium_bonds = 'yes' }

      it { is_expected.to validate_presence_of(:premium_bonds_total_value) }
      it { is_expected.to validate_presence_of(:premium_bonds_holder_number) }
    end

    context 'when has premium bonds answered no' do
      before { form.has_premium_bonds = 'no' }

      it { is_expected.not_to validate_presence_of(:premium_bonds_total_value) }
      it { is_expected.not_to validate_presence_of(:premium_bonds_holder_number) }
    end
  end

  describe '#save' do
    context 'for valid details' do
      before do
        allow(capital).to receive(:update).and_return(true)

        form.has_premium_bonds = has_premium_bonds
        form.premium_bonds_total_value = '100023.00'
        form.premium_bonds_holder_number = '123568A'

        subject.save
      end

      context 'when has premium bonds answered yes' do
        let(:has_premium_bonds) { 'yes' }

        let(:expected_args) do
          {
            has_premium_bonds: YesNoAnswer::YES,
            premium_bonds_total_value: '100023.00',
            premium_bonds_holder_number: '123568A'
          }
        end

        it 'updates capital with premium bond details' do
          expect(capital).to have_received(:update).with(expected_args.stringify_keys)
        end
      end

      context 'when has premium bonds answered no' do
        let(:has_premium_bonds) { 'no' }

        let(:expected_args) do
          {
            has_premium_bonds: YesNoAnswer::NO,
            premium_bonds_total_value: nil,
            premium_bonds_holder_number: nil
          }.stringify_keys
        end

        it 'updates the record and sets the detail attributes to nil' do
          expect(capital).to have_received(:update).with(expected_args)
        end
      end
    end
  end
end
