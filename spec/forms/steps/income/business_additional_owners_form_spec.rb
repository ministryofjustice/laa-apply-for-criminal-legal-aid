require 'rails_helper'

RSpec.describe Steps::Income::BusinessAdditionalOwnersForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record) { Business.new }
  let(:attributes) { {} }

  it_behaves_like 'a form with a from_subject'

  describe 'validations' do
    it { is_expected.to validate_presence_of(:has_additional_owners, :inclusion) }
    it { is_expected.not_to validate_presence_of(:additional_owners) }

    context 'has additional owners' do
      before { form.has_additional_owners = 'yes' }

      it { is_expected.to validate_presence_of(:additional_owners) }
    end
  end

  describe '#save' do
    context 'when valid' do
      let(:attributes) { { has_additional_owners: 'no' } }

      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when invalid' do
      let(:attributes) { { has_additional_owners: 'yes' } }

      it 'does not update record' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(false)
      end
    end
  end
end
