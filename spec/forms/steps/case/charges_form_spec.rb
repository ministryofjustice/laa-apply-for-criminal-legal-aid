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

  describe '#offence_dates' do
    it 'returns a list of offence date fieldset forms' do
      charge_record.offence_dates << [
        OffenceDate.new(date: "02, 02, 2000"),
        OffenceDate.new(date: "03, 10, 1998"),
        OffenceDate.new(date: "11, 12, 2021")
      ]

      expect(subject.offence_dates).to all(be_a(Steps::Case::OffenceDateFieldsetForm))
      expect(subject.offence_dates.size).to be(3)
    end
  end

  describe '#show_destroy?' do
    it 'returns false if there are fewer than 2 offence dates' do
      charge_record.offence_dates << [
        OffenceDate.new(date: "11, 12, 2021")
      ]

      expect(subject.show_destroy?).to be(false)
    end

    it 'returns true if there are more than 2 offence dates' do
      charge_record.offence_dates << [
        OffenceDate.new(date: "11, 12, 2021"),
        OffenceDate.new(date: "03, 10, 1998")
      ]

      expect(subject.show_destroy?).to be(true)
    end
  end
end
