require 'rails_helper'

RSpec.describe Steps::Case::ChargesForm do
  let(:arguments) { {
    crime_application: crime_application,
    record: charge_record,
    offence_name: offence_name,
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:charge_record) { Charge.new }
  let(:offence_name) { 'Robbery' }

  subject { described_class.new(arguments) }

  describe 'validations' do
    # TODO: validations
  end

  describe '#save' do
    context 'for valid details' do
      it 'updates the record' do
        expect(charge_record).to receive(:update).with(
          'offence_name' => 'Robbery',
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
