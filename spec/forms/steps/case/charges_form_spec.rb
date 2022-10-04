require 'rails_helper'

RSpec.describe Steps::Case::ChargesForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
    record: charge_record,
    offence_name: offence_name,
    offence_dates_attributes: offence_dates_attributes
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:charge_record) { Charge.new }
  let(:offence_name) { 'Robbery' }
  let(:offence_dates_attributes) do
    {
      '0' => { 'date(3i)' => '03', 'date(2i)' => '11', 'date(1i)' => '2000' },
     '1' => { 'date(3i)' => '11', 'date(2i)' => '07', 'date(1i)' => '2010' },
     '2' => { 'date(3i)' => '10', 'date(2i)' => '02', 'date(1i)' => '2009' }
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:offence_name) }

    context 'offence dates' do
      let(:offence_dates_attributes) do
        {
          '0' => { 'date(3i)' => '03', 'date(2i)' => '11', 'date(1i)' => '3000' },
          '1' => { 'date(3i)' => '', 'date(2i)' => '', 'date(1i)' => '' },
        }
      end

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'sets the errors with their index' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?('offence_dates-attributes[0].date', :future_not_allowed)).to be(true)

        expect(subject.errors.messages_for('offence_dates-attributes[0].date').first).to eq(
          'Offence dates cannot be in the future'
        )

        expect(subject.errors.of_kind?('offence_dates-attributes[1].date', :blank)).to be(true)

        expect(subject.errors.messages_for('offence_dates-attributes[1].date').first).to eq(
          'Offence dates cannot be blank'
        )
      end
    end

    describe '#any_marked_for_destruction?' do
      # NOTE: this scenario requires real DB records to exercise nested attributes
      context 'there are offence dates marked for destruction' do
        let(:application) { CrimeApplication.create }
        let(:case_record) { Case.create(crime_application: application) }

        let(:offence_dates) do
          [
            OffenceDate.new(date: Date.new(2000, 11, 3)),
            OffenceDate.new(date: Date.new(2009, 5, 1))
          ]
        end

        let(:charge_record) { Charge.create(case: case_record, offence_dates: offence_dates) }

        let(:offence_dates_attributes) do
          {
            '0' => {
              'id' => offence_dates[0].id.to_s,
              'date(3i)' => '03',
              'date(2i)' => '11',
              'date(1i)' => '2000',
              '_destroy' => '1'
            },
            '1' => {
              'id' => offence_dates[1].id.to_s,
              'date(3i)' => '01',
              'date(2i)' => '05',
              'date(1i)' => '2009'
            }
          }
        end

        it 'returns true' do
          expect(subject.any_marked_for_destruction?).to be(true)
          expect(subject.offence_dates[0]._destroy).to be(true)
          expect(subject.offence_dates[1]._destroy).to be(false)
        end
      end

      context 'there are no offence_dates to be destroyed' do
        it { expect(subject.any_marked_for_destruction?).to be(false) }
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      it 'updates the record' do
        expect(charge_record).to receive(:update).with(
          'offence_name' => 'Robbery'
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end

  describe '#offence_dates' do
    it 'returns a list of offence date fieldset forms' do
      expect(subject.offence_dates).to all(be_a(Steps::Case::OffenceDateFieldsetForm))
      expect(subject.offence_dates.size).to be(3)
    end
  end

  describe '#show_destroy?' do
    context 'if there are fewer than two offence dates' do
      let(:offence_dates_attributes) do
        {
          '0' => { 'date(3i)' => '03', 'date(2i)' => '11', 'date(1i)' => '2000' },
        }
      end

      it 'returns false' do
        expect(subject.show_destroy?).to be(false)
      end
    end

    context 'if there two or more offence dates' do
      let(:offence_dates_attributes) do
        {
          '0' => { 'date(3i)' => '03', 'date(2i)' => '11', 'date(1i)' => '2000' },
          '1' => { 'date(3i)' => '11', 'date(2i)' => '07', 'date(1i)' => '2010' }
        }
      end

      it 'returns true' do
        expect(subject.show_destroy?).to be(true)
      end
    end
  end
end
