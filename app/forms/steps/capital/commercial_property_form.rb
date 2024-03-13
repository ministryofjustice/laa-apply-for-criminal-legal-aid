module Steps
  module Capital
    class CommercialPropertyForm < PropertyForm
      attribute :usage, :string

      validates :usage, presence: true
    end
  end
end
