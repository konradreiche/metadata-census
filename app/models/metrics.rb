module Metrics

  ##
  # Normalizes values based on input data.
  #
  def self.normalize(data, values)
    max = data.max
    min = data.min

    range = max - min
    values.map { |value| (value - min) / range }
  end

  ##
  # Creates a metric class object based on its symbol representation.
  #
  def self.from_sym(symbol)
    "#{self.name}::#{symbol.to_s.underscore.camelcase}".constantize
  end


  ##
  # Tests if a value is blank according to the rule set of metric computations.
  #
  def self.blank?(value)
    value.nil? || value.is_a?(Boolean) || value.is_a?(Fixnum) ||
      value.empty? || (value.is_a?(String) && value !~ /[^[:space:]]/)
  end

end
