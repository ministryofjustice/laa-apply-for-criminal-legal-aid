class EmploymentsPayment < ApplicationRecord
  belongs_to :employment
  belongs_to :payment
end
