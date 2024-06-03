require 'rails_helper'

RSpec.describe Steps::Partner::DetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: partner_record,
    }.merge(form_attributes)
  end

  let(:form_attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      other_names: nil,
      date_of_birth: 20.years.ago.to_date,
    }
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      partner: partner_record,
      partner_detail: partner_detail
    )
  end

  let(:partner_record) { Partner.new }
  let(:partner_detail) { instance_double(PartnerDetail) }

  describe '#save' do
    context 'validations' do
      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_presence_of(:date_of_birth) }
      it { is_expected.not_to validate_presence_of(:other_names) }
    end

    context 'date_of_birth' do
      it_behaves_like 'a multiparam date validation', attribute_name: :date_of_birth
    end

    context 'when details are valid' do
      let(:partner_record) { Partner.new(form_attributes) }

      before do
        partner_record.crime_application = CrimeApplication.new
      end

      it 'saves the record' do
        expect(partner_record).to receive(:update!).with(form_attributes.stringify_keys).and_return(true)

        partner_record.first_name = 'Ella'
        expect(subject.save).to be(true)
      end

      it 'does not update unchanged details' do
        expect(partner_record).not_to receive(:update!)
        expect(partner_detail).not_to receive(:update!)

        expect(subject.save).to be(true)
      end
    end
  end
end
