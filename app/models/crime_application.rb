class CrimeApplication < ApplicationRecord
  has_one :applicant_detail, dependent: :destroy
end
