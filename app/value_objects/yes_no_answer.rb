class YesNoAnswer < ValueObject
  VALUES = [
    YES = new(:yes),
    NO  = new(:no)
  ].freeze

  def self.values
    VALUES
  end

  def yes?
    value == :yes
  end

  def no?
    value == :no
  end
end
