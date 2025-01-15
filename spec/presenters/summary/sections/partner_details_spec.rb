require 'rails_helper'

describe Summary::Sections::PartnerDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      partner: partner,
    )
  end

  let(:applicant) do
    double(Applicant, relationship_to_partner: 'married_or_partnership')
  end

  let(:partner) do
    double(
      Partner,
      first_name: 'Drew',
      last_name: 'Barlow',
      other_names: '',
      date_of_birth: Date.new(1999, 1, 20),
      nino: nino,
      arc: arc,
      involvement_in_case: 'codefendant',
      conflict_of_interest: 'no',
      has_same_address_as_client: has_same_address_as_client,
      home_address: home_address
    )
  end

  let(:nino) { '123456' }
  let(:has_nino) { 'yes' }
  let(:arc) { nil }
  let(:has_arc) { nil }
  let(:has_same_address_as_client) { 'no' }
  let(:home_address) do
    HomeAddress.new(
      id: 'ff53a8dd-43f3-4e82-acba-53b1c0ce2b4c',
      address_line_one: 'Test',
      address_line_two: 'Home',
      postcode: 'Postcode',
      city: 'City',
      country: 'Country',
    )
  end

  before do
    allow(partner).to receive_messages(
      has_nino:,
      has_arc:
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:partner_details) }
  end

  describe '#show?' do
    context 'when there is an applicant and partner present' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no applicant' do
      let(:applicant) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end

    context 'when there is no partner' do
      let(:partner) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    client_partner_same_address_path = 'applications/12345/steps/partner/do-client-and-partner-live-same-address'

    it 'has the correct rows' do
      expect(answers.count).to eq(10)

      expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[0].question).to eq(:relationship_to_partner)
      expect(answers[0].change_path).to match('applications/12345/steps/partner/client-relationship-to-partner')
      expect(answers[0].value).to eq('married_or_partnership')

      expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[1].question).to eq(:first_name)
      expect(answers[1].change_path).to match('applications/12345/steps/partner/partner-details')
      expect(answers[1].value).to eq('Drew')

      expect(answers[2]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[2].question).to eq(:last_name)
      expect(answers[2].change_path).to match('applications/12345/steps/partner/partner-details')
      expect(answers[2].value).to eq('Barlow')

      expect(answers[3]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[3].question).to eq(:other_names)
      expect(answers[3].change_path).to match('applications/12345/steps/partner/partner-details')
      expect(answers[3].value).to eq('')

      expect(answers[4]).to be_an_instance_of(Summary::Components::DateAnswer)
      expect(answers[4].question).to eq(:date_of_birth)
      expect(answers[4].change_path).to match('applications/12345/steps/partner/partner-details')
      expect(answers[4].value).to eq(Date.new(1999, 1, 20))

      expect(answers[5]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[5].question).to eq(:nino)
      expect(answers[5].change_path).to match('applications/12345/steps/partner/nino')
      expect(answers[5].value).to eq('123456')

      expect(answers[6]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[6].question).to eq(:involvement_in_case)
      expect(answers[6].change_path).to match('applications/12345/steps/partner/partner-involved-in-case')
      expect(answers[6].value).to eq('codefendant')

      expect(answers[7]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[7].question).to eq(:conflict_of_interest)
      expect(answers[7].change_path).to match('applications/12345/steps/partner/partner-conflict-of-interest')
      expect(answers[7].value).to eq('no')

      expect(answers[8]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[8].question).to eq(:has_same_address_as_client)
      expect(answers[8].change_path).to match(client_partner_same_address_path)
      expect(answers[8].value).to eq('no')

      expect(answers[9]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[9].question).to eq(:home_address)
      expect(answers[9].change_path).to be_nil
      expect(answers[9].value).to eq("Test\r\nHome\r\nCity\r\nPostcode\r\nCountry")
    end

    context 'when partner has same home address as client' do
      let(:has_same_address_as_client) { 'yes' }
      let(:home_address) { nil }

      it 'has the correct rows' do
        expect(answers.count).to eq(9)

        expect(answers[8]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[8].question).to eq(:has_same_address_as_client)
        expect(answers[8].change_path).to match(client_partner_same_address_path)
        expect(answers[8].value).to eq('yes')
      end
    end

    context 'when an arc is provided' do
      let(:nino) { nil }
      let(:arc) { 'ABC12/345678/A' }
      let(:has_arc) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(10)

        expect(answers[5]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[5].question).to eq(:arc)
        expect(answers[5].change_path).to match('applications/12345/steps/partner/nino')
        expect(answers[5].value).to eq('ABC12/345678/A')
      end
    end
  end
end
