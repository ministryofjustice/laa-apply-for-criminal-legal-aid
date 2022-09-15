require 'rails_helper'

RSpec.describe Steps::Case::OffenceDateFieldsetForm do
  let(:arguments) { {
    crime_application: crime_application,
    record: OffenceDate.new(date: "02, 07, 2020")
  } }

  let(:crime_application) { instance_double(CrimeApplication) }

  subject { described_class.new(arguments) }

  describe 'validations' do
    # TODO: validations
  end

  describe '#persisted?' do
    context 'when form has an id' do
      it 'it returns true' do
        arguments[:id] = "1232456"

        expect(subject.persisted?).to be(true)
      end
    end

    context 'when form has no id' do
      it 'it returns false' do
        expect(subject.persisted?).to be(false)
      end
    end
  end
end
