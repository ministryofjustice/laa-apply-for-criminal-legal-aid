class Provider < ApplicationRecord
  devise :lockable, :timeoutable, :trackable
end
