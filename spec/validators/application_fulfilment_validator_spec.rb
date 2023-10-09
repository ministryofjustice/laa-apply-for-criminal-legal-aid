require 'rails_helper'

module Test
  CrimeApplicationValidatable = Struct.new(:ioj, :documents, keyword_init: true) do
    include ActiveModel::Validations
    validates_with ApplicationFulfilmentValidator

    def to_param
      '12345'
    end
  end
end

RSpec.describe ApplicationFulfilmentValidator, type: :model do
  subject { Test::CrimeApplicationValidatable.new(arguments) }

  let(:arguments) do
    {
      ioj:,
      documents:
    }
  end

  let(:ioj) { instance_double(Ioj, types: ioj_types) }
  let(:ioj_types) { [] }

  let(:documents) { double(stored: stored_documents) }
  let(:stored_documents) { [] }

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

      context 'and evidence has not been uploaded' do
        let(:stored_documents) { [] }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:means_passport, :blank)).to be(true)
          expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/client/details')
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
end
