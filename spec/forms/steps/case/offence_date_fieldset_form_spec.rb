require 'rails_helper'

RSpec.describe Steps::Case::OffenceDateFieldsetForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: OffenceDate.new(date: '02, 07, 2020'),
      id: record_id
    }
  end

  let(:record_id) { '123456' }
  let(:crime_application) { instance_double(CrimeApplication) }

  # TODO: validations

  describe '#persisted?' do
    context 'when form has an id' do
      it 'returns true' do
        expect(subject.persisted?).to be(true)
      end
    end

    context 'when form has no id' do
      let(:record_id) { nil }

      it 'returns false' do
        expect(subject.persisted?).to be(false)
      end
    end
  end
end
