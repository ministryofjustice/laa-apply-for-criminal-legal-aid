require 'rails_helper'

describe Summary::Sections::ContactDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
    )
  end

  let(:applicant) do
    instance_double(
      Applicant,
      home_address:,
      correspondence_address:,
      correspondence_address_type:,
      telephone_number:,
      residence_type:,
      relationship_to_owner_of_usual_home_address:
    )
  end

  let(:telephone_number) { '123456789' }
  let(:correspondence_address_type) { CorrespondenceType::OTHER_ADDRESS.to_s }
  let(:residence_type) { nil }
  let(:relationship_to_owner_of_usual_home_address) { nil }

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

  let(:correspondence_address) do
    CorrespondenceAddress.new(
      id: 'e77e4fa3-76f1-4db6-8b92-72b36c8b327a',
      lookup_id: 123,
      address_line_one: 'Test',
      address_line_two: 'Correspondence',
      postcode: 'Postcode',
      city: 'City',
      country: 'Country',
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:contact_details) }
  end

  describe '#show?' do
    let(:appeal_no_changes?) { false }

    before do
      allow(crime_application).to receive_messages(appeal_no_changes?: appeal_no_changes?)
    end

    context 'when there is an applicant' do
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

    context 'when case type is appeal no changes' do
      let(:appeal_no_changes?) { true }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there is no residence type record' do
      it 'has the correct rows' do
        expect(answers.count).to eq(4)

        expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[0].question).to eq(:home_address)
        expect(answers[0].change_path).to match('applications/12345/steps/address/details/ff53a8dd')
        expect(answers[0].value).to eq("Test\r\nHome\r\nCity\r\nPostcode\r\nCountry")

        expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[1].question).to eq(:correspondence_address_type)
        expect(answers[1].change_path).to match('applications/12345/steps/client/contact-details')
        expect(answers[1].value).to eq('other_address')

        expect(answers[2]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[2].question).to eq(:correspondence_address)
        expect(answers[2].change_path).to match('applications/12345/steps/address/results/e77e4fa3')
        expect(answers[2].value).to eq("Test\r\nCorrespondence\r\nCity\r\nPostcode\r\nCountry")

        expect(answers[3]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[3].question).to eq(:telephone_number)
        expect(answers[3].change_path).to match('applications/12345/steps/client/contact-details')
        expect(answers[3].value).to eq('123456789')
      end
    end

    context 'when there is a residence type' do
      let(:residence_type) { ResidenceType::PARENTS.to_s }

      it 'has the correct rows' do
        expect(answers.count).to eq(5)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:residence_type)
        expect(answers[0].change_path).to match('/applications/12345/steps/client/residence-type')
        expect(answers[0].value).to eq('parents')
      end

      context 'when residence type is `someone else`' do
        let(:residence_type) { ResidenceType::SOMEONE_ELSE.to_s }
        let(:relationship_to_owner_of_usual_home_address) { 'A friend' }

        it 'has the correct rows' do
          expect(answers.count).to eq(6)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:residence_type)
          expect(answers[0].change_path).to match('/applications/12345/steps/client/residence-type')
          expect(answers[0].value).to eq('someone_else')

          expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
          expect(answers[1].question).to eq(:relationship_to_owner_of_usual_home_address)
          expect(answers[1].change_path).to match('/applications/12345/steps/client/residence-type')
          expect(answers[1].value).to eq('A friend')
        end
      end
    end

    context 'when client has no home address' do
      # NOTE: a DB record will always be present, but its attributes will be nil
      let(:home_address) { HomeAddress.new(id: 'ff53a8dd-43f3-4e82-acba-53b1c0ce2b4c') }

      it 'has the correct rows' do
        expect(answers.count).to eq(4)

        expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[0].question).to eq(:home_address)
        expect(answers[0].change_path).to match('applications/12345/steps/address/lookup/ff53a8dd')
        expect(answers[0].value).to eq('')
      end

      context 'when residence type = none' do
        let(:residence_type) { ResidenceType::NONE.to_s }

        it 'does not display home address as it was not asked' do
          expect(answers.count).to eq(4)

          expect(answers[0].question).not_to eq(:home_address)
          expect(answers[0].question).to eq(:residence_type)
        end
      end
    end

    context 'for `home_address` correspondence type' do
      let(:correspondence_address_type) { CorrespondenceType::HOME_ADDRESS.to_s }
      let(:correspondence_address) { nil }

      it 'does not show the correspondence address' do
        expect(answers.count).to eq(3)

        expect(answers[0].question).to eq(:home_address)

        expect(answers[1].question).to eq(:correspondence_address_type)
        expect(answers[1].value).to eq('home_address')

        expect(answers[2].question).to eq(:telephone_number)
      end
    end

    context 'for `providers_office_address` correspondence type' do
      let(:correspondence_address_type) { CorrespondenceType::PROVIDERS_OFFICE_ADDRESS.to_s }
      let(:correspondence_address) { nil }

      it 'does not show the correspondence address' do
        expect(answers.count).to eq(3)

        expect(answers[0].question).to eq(:home_address)

        expect(answers[1].question).to eq(:correspondence_address_type)
        expect(answers[1].value).to eq('providers_office_address')

        expect(answers[2].question).to eq(:telephone_number)
      end
    end

    context 'when there is no telephone number' do
      let(:telephone_number) { '' }

      it 'has the correct rows' do
        expect(answers.count).to eq(4)

        expect(answers[3].question).to eq(:telephone_number)
        expect(answers[3].value).to eq('')
      end
    end
  end
end
