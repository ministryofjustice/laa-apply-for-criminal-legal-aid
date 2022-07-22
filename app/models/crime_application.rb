class CrimeApplication < ApplicationRecord
  has_one :applicant_details, class_name: 'ApplicantDetails', dependent: :destroy
end
