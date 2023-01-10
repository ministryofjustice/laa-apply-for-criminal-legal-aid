require 'rails_helper'

RSpec.describe Adapters::Structs::Charge do
  subject { application_struct.case.charges.first }

  let(:application_struct) do
    Adapters::Structs::CrimeApplication.new(
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  describe '#to_param' do
    it 'has a nil UUID, as it is not used or needed' do
      expect(subject.to_param).to eq(Adapters::Structs::BaseStructAdapter::NIL_UUID)
    end
  end

  describe 'delegated class' do
    it 'is a `Charge` ActiveRecord model' do
      expect(subject.__getobj__).to be_a(Charge)
    end
  end

  describe '#offence' do
    it 'returns the offence value object' do
      expect(subject.offence).to be_an(Offence)
    end
  end

  describe '#offence_dates' do
    it 'returns the mapped dates' do
      expect(
        subject.offence_dates
      ).to match_array([{ date_from: kind_of(Date) }, { date_from: kind_of(Date) }])
    end
  end

  describe '#complete?' do
    it 'returns always true' do
      expect(subject.complete?).to be(true)
    end
  end
end
