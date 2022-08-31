require 'rails_helper'

RSpec.describe Steps::Case::CodefendantFieldsetForm do
  let(:arguments) { {
    crime_application: crime_application,
    id: record_id,
    first_name: 'John',
    last_name: 'Doe',
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record_id) { '12345' }

  subject { described_class.new(arguments) }

  describe '#persisted?' do
    context 'when the record has an ID' do
      it { expect(subject.persisted?).to eq(true) }
    end

    context 'when the record has no ID' do
      let(:record_id) { nil }
      it { expect(subject.persisted?).to eq(false) }
    end
  end

  context 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end
end
