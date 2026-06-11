require 'rails_helper'

describe Summary::Sections::OtherCapitalDetails do
  subject(:section) { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      capital: capital
    )
  end

  let(:capital) do
    instance_double(
      Capital,
      has_frozen_income_or_assets: 'yes',
      frozen_income_or_assets_subject: 'client'
    )
  end

  describe '#show?' do
    context 'when capital exists' do
      it { expect(section.show?).to be(true) }
    end

    context 'when capital is nil' do
      let(:capital) { nil }

      it { expect(section.show?).to be(false) }
    end
  end

  describe '#answers' do
    let(:answers) { section.answers }

    it 'contains the expected rows' do
      expect(answers.count).to eq(2)

      expect(answers[0].question).to eq(:has_frozen_income_or_assets)
      expect(answers[0].value).to eq('yes')

      expect(answers[1].question).to eq(:frozen_income_or_assets_subject)
      expect(answers[1].value).to eq('client')
    end

    context 'when frozen_income_or_assets_subject is nil' do
      let(:capital) do
        instance_double(
          Capital,
          has_frozen_income_or_assets: 'no',
          frozen_income_or_assets_subject: nil
        )
      end

      it 'does not show the subject row' do
        expect(section.answers.count).to eq(1)
      end
    end
  end
end
