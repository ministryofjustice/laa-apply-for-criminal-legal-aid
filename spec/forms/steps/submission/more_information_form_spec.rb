require 'rails_helper'

RSpec.describe Steps::Submission::MoreInformationForm do
  subject(:form) { described_class.new(arguments) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:additional_information_required) { YesNoAnswer::YES }
  let(:additional_information) { '' }
  let(:arguments) do
    {
      crime_application:,
    additional_information_required:,
    additional_information:,
    }
  end

  before do
    allow(crime_application).to receive(:additional_information)
      .and_return(additional_information)
  end

  describe 'validations' do
    context 'when additional information is required' do
      let(:additional_information_required) { YesNoAnswer::YES }

      it { is_expected.to validate_presence_of(:additional_information) }
    end

    context 'when additional information is not needed' do
      let(:additional_information_required) { YesNoAnswer::NO }

      it { is_expected.not_to validate_presence_of(:additional_information) }
    end
  end

  describe '#save' do
    context 'when `additional_information_required` is blank' do
      let(:additional_information_required) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:additional_information_required, :inclusion)).to be(true)
      end
    end

    context 'when `additional_information_required` is invalid' do
      let(:additional_information_required) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:additional_information_required, :inclusion)).to be(true)
      end
    end

    context 'when `additional_information_required` is `NO`' do
      let(:additional_information_required) { YesNoAnswer::NO.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:additional_information_required, :invalid)).to be(false)
      end

      it 'updates the record' do
        expect(crime_application).to receive(:update)
          .with({
                  'additional_information_required' => YesNoAnswer::NO,
                                       'additional_information' => nil
                })
          .and_return(true)

        expect(form.save).to be(true)
      end
    end

    context 'when `additional_information_required` is `YES`' do
      let(:additional_information_required) { YesNoAnswer::YES.to_s }

      context 'when `additional_information` is blank' do
        it 'has is a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:additional_information, :blank)).to be(true)
        end
      end

      context 'when `additional_information` is not blank' do
        let(:additional_information) { 'More information about this application.' }

        it 'there is no validation error on the field' do
          expect(form).to be_valid
          expect(form.errors.of_kind?(:additional_information, :blank)).to be(false)
        end
      end
    end

    context 'when text for `additional_information` was previously recorded' do
      let(:additional_information) { 'Details entered previously' }

      context 'when NO is selected for `additional_information_required`' do
        let(:additional_information_required) { YesNoAnswer::NO.to_s }

        it 'resets `additional_information` to nil before saving' do
          form.send(:before_save)
          expect(form.attributes['additional_information']).to be_nil
        end
      end
    end
  end

  describe '#choices' do
    subject(:choices) { form.choices }

    it { is_expected.to be YesNoAnswer.values }
  end
end
