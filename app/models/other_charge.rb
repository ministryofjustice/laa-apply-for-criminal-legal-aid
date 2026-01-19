class OtherCharge < ApplicationRecord
  belongs_to :case, touch: true
end
