require 'rails_helper'

describe Summary::Sections::Codefendants do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      case: kase,
    )
  end

  let(:kase) do
    instance_double(
      Case,
      has_codefendants: 'yes',
      codefendants: [codefendant_one, codefendant_two],
    )
  end

  let(:codefendant_one) do
    Codefendant.new(
      first_name: 'John',
      last_name: 'Doe',
      conflict_of_interest: conflict_of_interest,
    )
  end

  let(:codefendant_two) do
    Codefendant.new(
      first_name: 'Jane',
      last_name: 'Doe',
      conflict_of_interest: 'no',
    )
  end

  let(:conflict_of_interest) { 'yes' }

  describe '#name' do
    it { expect(subject.name).to eq(:codefendants) }
  end

  describe '#show?' do
    context 'when there is a case' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no case' do
      let(:kase) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    it 'has the correct rows' do
      expect(answers.count).to eq(3)

      expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[0].question).to eq(:has_codefendants)
      expect(answers[0].change_path).to match('applications/12345/steps/case/has_codefendants')
      expect(answers[0].value).to eq('yes')

      expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[1].question).to eq(:codefendant_full_name)
      expect(answers[1].change_path).to match('applications/12345/steps/case/codefendants#codefendant_1')
      expect(answers[1].value).to eq('John Doe<span class="govuk-caption-m">Conflict of interest</span>')
      expect(answers[1].i18n_opts).to eq({ index: 1 })

      expect(answers[2]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[2].question).to eq(:codefendant_full_name)
      expect(answers[2].change_path).to match('applications/12345/steps/case/codefendants#codefendant_2')
      expect(answers[2].value).to eq('Jane Doe<span class="govuk-caption-m">No conflict of interest</span>')
      expect(answers[2].i18n_opts).to eq({ index: 2 })
    end
  end
end
