require 'rails_helper'

RSpec.describe Steps::Case::ChargesForm do
  let(:arguments) { {
    crime_application: crime_application,
    record: charge_record,
    offence_name: offence_name,
    offence_dates_attributes: offence_dates_attributes
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:charge_record) { Charge.new }
  let(:offence_name) { 'Robbery' }
  let(:offence_dates_attributes) {
    {
     '0'=>{ 'date(3i)'=>'03', 'date(2i)'=>'11', 'date(1i)'=>'2000' },
     '1'=>{ 'date(3i)'=>'11', 'date(2i)'=>'07', 'date(1i)'=>'2010' },
     '2'=>{ 'date(3i)'=>'10', 'date(2i)'=>'02', 'date(1i)'=>'2009' }
    }
  }

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
      expect(subject.offence_dates).to all(be_a(Steps::Case::OffenceDateFieldsetForm))
      expect(subject.offence_dates.size).to be(3)
    end
  end

  describe '#show_destroy?' do
    context 'if there are fewer than two offence dates' do
      let(:offence_dates_attributes) {
        {
         '0'=>{ 'date(3i)'=>'03', 'date(2i)'=>'11', 'date(1i)'=>'2000' },
        }
      }
      it 'returns false' do
        expect(subject.show_destroy?).to be(false)
      end
    end

    context 'if there two or more offence dates' do
      let(:offence_dates_attributes) {
        {
          '0'=>{ 'date(3i)'=>'03', 'date(2i)'=>'11', 'date(1i)'=>'2000' },
          '1'=>{ 'date(3i)'=>'11', 'date(2i)'=>'07', 'date(1i)'=>'2010' }
        }
      }
      it 'returns true' do
        expect(subject.show_destroy?).to be(true)
      end
    end
  end
end
