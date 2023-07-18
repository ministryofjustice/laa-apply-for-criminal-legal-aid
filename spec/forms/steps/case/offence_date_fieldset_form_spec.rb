require 'rails_helper'

RSpec.describe Steps::Case::OffenceDateFieldsetForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      id: record_id,
      date_from: record.date_from,
      date_to: record.date_to,
    }
  end

  let(:record) { OffenceDate.new(date_from: Date.new(2020, 7, 2)) }
  let(:record_id) { '123456' }
  let(:crime_application) { instance_double(CrimeApplication) }

  describe 'validations' do
    describe '#date_from' do
      it { is_expected.to validate_presence_of(:date_from) }

      it_behaves_like 'a multiparam date validation',
                      attribute_name: :date_from,
                      restrict_past_under_ten_years: false
    end

    describe '#date_to' do
      it { is_expected.not_to validate_presence_of(:date_to) }

      it_behaves_like 'a multiparam date validation',
                      attribute_name: :date_to,
                      restrict_past_under_ten_years: false
    end

    context '`date_to` is before `date_from`' do
      let(:record) do
        OffenceDate.new(date_from: Date.new(2020, 7, 18), date_to: Date.new(2020, 7, 2))
      end

      it 'has a validation error on the `date_to` field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(:date_to, :before_date_from)).to be(true)
      end
    end
  end

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
