require 'rails_helper'

module Test
  PseApplicationValidatable = Struct.new(:documents, keyword_init: true) do
    include ActiveModel::Validations

    validates_with PseFulfilmentValidator

    def to_param
      '12345'
    end
  end
end

RSpec.describe PseFulfilmentValidator, type: :model do
  subject { Test::PseApplicationValidatable.new(arguments) }

  let(:arguments) do
    { documents: }
  end

  let(:documents) { double(stored: stored_documents) }
  let(:stored_documents) { [] }

  context 'Pse validation' do
    context 'when the pse application does not have uploaded evidence' do
      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:documents, :blank)).to be(true)
        expect(subject.errors.first.details[:change_path]).to eq('/applications/12345/steps/evidence/upload')
      end
    end

    context 'when the pse application has uploaded evidence' do
      let(:stored_documents) { [Document.new] }

      it 'is valid' do
        expect(subject).to be_valid
        expect(subject.errors.of_kind?(:documents, :blank)).not_to be(true)
      end
    end
  end
end
