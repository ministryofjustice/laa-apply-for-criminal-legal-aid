require 'rails_helper'

RSpec.describe Document, type: :model do
  subject { described_class.new(attributes) }

  include_context 'with an existing document'

  describe '.create_from_file' do
    it 'creates a record with the expected file attributes' do
      expect(
        described_class
      ).to receive(:create).with(
        crime_application: crime_application,
        filename: 'test.pdf',
        content_type: 'application/pdf',
        file_size: 14_077,
        tempfile: kind_of(Tempfile),
      )

      described_class.create_from_file(file:, crime_application:)
    end
  end

  describe 'validations' do
    let(:attributes) do
      {
        crime_application: crime_application,
        filename: 'test.pdf',
        content_type: 'application/pdf',
        file_size: 1.megabyte,
      }
    end

    context 'criteria' do
      context 'file is too small' do
        let(:attributes) { super().merge(file_size: 2.kilobytes) }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid(:criteria)
          expect(subject.errors.of_kind?(:file_size, :too_small)).to be(true)
        end
      end

      context 'file is too big' do
        let(:attributes) { super().merge(file_size: 11.megabytes) }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid(:criteria)
          expect(subject.errors.of_kind?(:file_size, :too_big)).to be(true)
        end
      end

      context 'content type not allowed' do
        let(:attributes) { super().merge(content_type: 'text/unknown') }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid(:criteria)
          expect(subject.errors.of_kind?(:content_type, :invalid)).to be(true)
        end
      end

      context 'more than one error' do
        let(:attributes) do
          super().merge(content_type: 'text/unknown', file_size: 11.megabytes, scan_status: 'flagged')
        end

        it 'has a validation error on all invalid fields' do
          expect(subject).not_to be_valid(:criteria)
          expect(subject.errors.size).to eq(2)
          expect(subject.errors.of_kind?(:file_size, :too_big)).to be(true)
          expect(subject.errors.of_kind?(:content_type, :invalid)).to be(true)
        end
      end
    end

    context 'scan' do
      context 'when flagged' do
        let(:attributes) { super().merge(scan_status: 'flagged') }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid(:scan)
          expect(subject.errors.of_kind?(:scan_status, :flagged)).to be(true)
        end
      end

      context 'when inconclusive' do
        let(:attributes) { super().merge(scan_status: 'other') }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid(:scan)
          expect(subject.errors.of_kind?(:scan_status, :inconclusive)).to be(true)
        end
      end
    end

    context 'storage' do
      context 'no other criteria has failed' do
        it 'has a validation error on the field' do
          expect(subject).not_to be_valid(:storage)
          expect(subject.errors.size).to eq(1)
          expect(subject.errors.of_kind?(:s3_object_key, :blank)).to be(true)
        end
      end

      context 'when some criteria also has failed' do
        let(:attributes) { super().merge(file_size: 11.megabytes) }

        it 'has a validation error on all invalid fields' do
          expect(subject).not_to be_valid(:storage)
          expect(subject.errors.size).to eq(2)
          expect(subject.errors.of_kind?(:file_size, :too_big)).to be(true)
          expect(subject.errors.of_kind?(:s3_object_key, :blank)).to be(true)
        end
      end

      context 'when file was successfully stored' do
        let(:attributes) { super().merge(s3_object_key: '12345/xyz') }

        it { expect(subject).to be_valid(:storage) }
      end
    end
  end
end
