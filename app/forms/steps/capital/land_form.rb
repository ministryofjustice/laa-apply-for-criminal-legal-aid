module Steps
  module Capital
    class LandForm < PropertyForm
      attribute :size_in_acres, :integer
      attribute :usage, :string

      validates :size_in_acres, :usage, presence: true
    end
  end
end
