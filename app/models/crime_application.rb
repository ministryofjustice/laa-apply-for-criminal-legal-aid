class CrimeApplication < ApplicationRecord
  has_one :applicant_details, class_name: 'ApplicantDetails', dependent: :destroy
  has_one :contact_details, class_name: 'ContactDetails', dependent: :destroy
end
