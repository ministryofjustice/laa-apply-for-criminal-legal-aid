class Money
  attr_reader :value

  def initialize(raw_value)
    @value = raw_value

    freeze
  end

  def ==(other)
    case other
    when Integer
      other == value
    else
      other.to_d == to_d
    end
  end
  alias === ==
  alias eql? ==

  def to_s
    return if value.nil?

    format('%0.02f', to_d)
  end

  def to_i
    value
  end

  def to_f
    value * 0.01
  end

  delegate :to_d, to: :to_f

  def zero?
    value.to_f.zero?
  end
end
