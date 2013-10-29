module Metrics

  def self.all
    initialize if Rails.env.development? or Rails.env.test?
    initialize_once if Rails.env.production?

    cls = Metrics::Metric
    cls.metrics
  end

  ## Eager load all metric classes
  # 
  # In development environment the metric classes are wiped per request. This
  # method helps to manually load them.
  #
  def self.initialize
    directory = self.to_s.downcase
    path = Rails.root.join("app/models/#{directory}/*.rb")
    Dir[path].each { |metric_file| load metric_file }
  end

  ##
  # Guard method to initialize metric classes just once
  #
  def self.initialize_once
    initialize unless defined? @initialized
    @initialized ||= true
  end

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
