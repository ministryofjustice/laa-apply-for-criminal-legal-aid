require 'rails_helper'

RSpec.describe DateStampContext, type: :model do
  let(:crime_application) { CrimeApplication.new(applicant:) }

  let(:applicant) do
    Applicant.new(
      first_name: 'Jason',
      last_name: 'Apple',
      other_names: 'Bruno',
      date_of_birth: Date.new(1990, 1, 1),
    )
  end

  describe '#new' do
    it 'does not store other_names' do
      expect(described_class.new).not_to respond_to :other_names
    end

    it 'allows hash attributes' do
      expect(described_class.new({ first_name: 'Jo' }).first_name).to eq 'Jo'
    end
  end

  describe '.build' do
    context 'when date_stamp not provided' do
      subject(:date_stamp_context) { described_class.build(crime_application) }

      it 'has expected attributes' do
        expect(subject.first_name).to eq 'Jason'
        expect(subject.last_name).to eq 'Apple'
        expect(subject.created_at).to be_a DateTime
        expect(subject.date_stamp).to respond_to :to_time
      end
    end

    context 'when date_stamp is provided' do
      subject(:date_stamp_context) { described_class.build(crime_application, date_stamp) }

      let(:date_stamp) { Time.new(2024, 4, 3, 2, 32, 10, 'UTC') }

      it 'has expected attributes' do
        expect(subject.first_name).to eq 'Jason'
        expect(subject.last_name).to eq 'Apple'
        expect(subject.created_at).to be_a DateTime
        expect(subject.date_stamp).to eq date_stamp
      end
    end
  end

  describe 'serialization and immutability' do
    it 'is hashable' do
      crime_application = CrimeApplication.new(date_stamp_context: { first_name: 'Jo' })
      crime_application.save!

      expect(crime_application.date_stamp_context.first_name).to eq 'Jo'
    end

    it 'is serializable from json string' do
      crime_application = CrimeApplication.new
      crime_application.date_stamp_context = { first_name: 'Jo' }.to_json
      crime_application.save!

      expect(crime_application.date_stamp_context.first_name).to eq 'Jo'
    end

    it 'is serializable from attributes hash' do
      crime_application = CrimeApplication.new
      crime_application.date_stamp_context = { attributes: { first_name: 'Jo' } }
      crime_application.save!

      expect(crime_application.date_stamp_context.first_name).to eq 'Jo'
    end

    it 'is serializable from simple hash' do
      crime_application = CrimeApplication.new
      crime_application.date_stamp_context = { first_name: 'Jo' }
      crime_application.save!

      expect(crime_application.date_stamp_context.first_name).to eq 'Jo'
    end

    it 'is immutable' do
      crime_application = CrimeApplication.new
      crime_application.date_stamp_context = described_class.new(
        first_name: 'Marie',
        last_name: 'Curie',
        date_of_birth: '1867-11-07',
        date_stamp: Time.current,
      )

      crime_application.save!

      # Cannot change...
      crime_application.date_stamp_context.first_name = 'Mariana'
      expect(crime_application.changed?).to be false
      crime_application.save!
      crime_application.reload

      expect(crime_application.date_stamp_context.first_name).to eq 'Marie'

      # ...but can be reset
      crime_application.date_stamp_context = nil
      crime_application.save!
      crime_application.reload

      expect(crime_application.date_stamp_context.first_name).to be_nil
    end
  end
end
