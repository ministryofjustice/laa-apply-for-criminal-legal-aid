require 'rails_helper'

module Test
  CrimeApplicationValidatable = Struct.new(:is_means_tested, :kase, :capital, :ioj, :income, :documents,
                                           :means_passport, keyword_init: true) do
    include ActiveModel::Validations
    validates_with ApplicationFulfilmentValidator

    def to_param
      '12345'
    end
  end
end

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe ApplicationFulfilmentValidator, type: :model do
  subject { Test::CrimeApplicationValidatable.new(arguments) }

  let(:arguments) do
    {
      is_means_tested:,
      kase:,
      ioj:,
      income:,
      capital:,
      documents:,
      means_passport:
    }
  end

  let(:is_means_tested) { 'yes' }
  let(:means_passport) { nil }

  let(:kase) {
    instance_double(Case, case_type:, is_client_remanded:, date_client_remanded:)
  }

  let(:capital) {
    instance_double(Capital)
  }

  let(:is_client_remanded) { nil }
  let(:date_client_remanded) { nil }

  let(:case_type) { 'either_way' }

  let(:ioj) { instance_double(Ioj, types: ioj_types) }
  let(:ioj_types) { [] }

  let(:income) { instance_double(Income, employment_status: employment_status, income_above_threshold: 'yes') }

  let(:employment_status) { [] }

  let(:documents) { double(stored: stored_documents) }
  let(:stored_documents) { [] }

  before do
    allow(capital).to receive(:complete?).and_return(true)
    allow(kase).to receive(:complete?).and_return(true)
  end

  context 'MeansPassporter validation' do
    before do
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(means_result)

      # stub the other validation
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(true)
    end

    context 'when the application is means-passported' do
      let(:means_result) { true }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when the application is not means-passported' do
      let(:means_result) { false }

      context 'and evidence has been uploaded' do
        let(:stored_documents) { ['stored_doc'] }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'and means details have been recorded' do
        let(:employment_status) { ['not_working'] }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'and evidence has not been uploaded' do
        let(:stored_documents) { [] }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:means_passport, :blank)).to be(true)
          expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/client/details')
        end
      end

      context 'and means details have not been recorded' do
        let(:employment_status) { [] }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:means_passport, :blank)).to be(true)
          expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/client/details')
        end
      end

      context 'and applicant is in Court Custody' do
        let(:is_client_remanded) { 'yes' }
        let(:date_client_remanded) { Time.zone.today }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  context 'IojPassporter validation' do
    before do
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(ioj_result)

      # stub the other validation
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(true)
    end

    context 'when the application is ioj-passported' do
      let(:ioj_result) { true }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when the application is not ioj-passported' do
      let(:ioj_result) { false }

      context 'and there are no IoJ reasons' do
        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:ioj_passport, :blank)).to be(true)
          expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/case/ioj')
        end
      end

      context 'and there are IoJ reasons' do
        let(:ioj_types) { [:foo, :bar] }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  context 'CaseType validation' do
    before do
      # stub the other validations
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(true)
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(true)
    end

    context 'when the application has a case type' do
      let(:case_type) { 'either_way' }
      let(:is_means_tested) { 'yes' }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when the application is missing a case type' do
      let(:case_type) { nil }

      context 'and application is not means tested' do
        let(:is_means_tested) { 'no' }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'and application is means tested' do
        let(:is_means_tested) { 'yes' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:base, :case_type_missing)).to be(true)
          expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/client/case_type')
        end
      end
    end
  end

  describe 'validating section completeness' do
    before do
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(means_result)
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(true)
    end

    let(:means_result) { true }

    it { is_expected.to be_valid }

    context 'when case section is not complete' do
      before do
        expect(kase).to receive(:complete?).and_return(false)
      end

      it { is_expected.not_to be_valid }

      it 'adds the incomplete record error to base' do
        subject.valid?
        expect(subject.errors.of_kind?(:base, :incomplete_records)).to be(true)
      end
    end

    context 'when not means tested' do
      let(:is_means_tested) { 'no' }

      context 'and capital section is not complete' do
        it { is_expected.to be_valid }
      end
    end

    context 'when means tested' do
      let(:means_result) { false }
      let(:employment_status) { ['not_working'] }

      context 'and capital section is not complete' do
        before do
          expect(capital).to receive(:complete?).and_return(false)
        end

        it { is_expected.not_to be_valid }

        it 'adds the incomplete record error to base' do
          subject.valid?
          expect(subject.errors.of_kind?(:base, :incomplete_records)).to be(true)
        end
      end

      context 'and capital section is not required' do
        let(:income) do
          instance_double(
            Income,
            employment_status: employment_status,
            income_above_threshold: 'no',
            has_frozen_income_or_assets: 'no',
            client_owns_property: 'no',
            has_savings: 'no'
          )
        end

        before do
          expect(capital).not_to receive(:complete?)

          subject.valid?
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
