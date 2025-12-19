require 'rails_helper'

RSpec.describe Steps::Case::ChargesForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: charge_record,
      offence_name: offence_name,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:charge_record) { Charge.new }
  let(:offence_name) { 'Robbery' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:offence_name) }
  end

  describe '#save' do
    context 'for valid details' do
      it 'updates the record' do
        expect(charge_record).to receive(:update).with(
          {
            'offence_name' => 'Robbery',
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
