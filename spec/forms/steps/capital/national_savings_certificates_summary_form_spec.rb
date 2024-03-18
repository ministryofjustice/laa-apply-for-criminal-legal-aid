require 'rails_helper'

RSpec.describe Steps::Capital::NationalSavingsCertificatesSummaryForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application: }.merge(attributes) }
  let(:crime_application) do
    instance_double(CrimeApplication)
  end
  let(:attributes) { {} }
  let(:application_certificates) { double }

  before do
    allow(crime_application).to receive(:national_savings_certificates) { application_certificates }
    allow(application_certificates).to receive(:create!).and_return(true)
  end

  describe '#save' do
    context 'when add national savings `no`' do
      before do
        form.add_national_savings_certificate = 'no'
      end

      it 'returns true but does not create a new certificate' do
        expect(subject.save).to be(true)
        expect(application_certificates).not_to have_received(:create!)
      end
    end

    context 'when add national savings `yes`' do
      before do
        form.add_national_savings_certificate = 'yes'
      end

      it 'creates a new certificate and returns true' do
        expect(subject.save).to be(true)
        expect(application_certificates).to have_received(:create!)
      end
    end

    context 'when add national savings is nil' do
      it 'adds errors and returns false' do
        expect(subject.save).to be(false)
        expect(application_certificates).not_to have_received(:create!)
      end
    end
  end
end
