module Metrics
  class Metric
    extend ActiveModel::Naming
    include Singleton

    attr_reader :configured

    @stripper = Regexp.compile(/(\p{Letter}.*\p{Letter})/)

    def initialize
      @configured = false
    end

    # @return [Metric] self for enabling method chaining
    def configure
      @configured = true
      self
    end

    # ActiveRecord fashioned accessor for all available metric objects.
    #
    # @return [Array<Metric>]
    def self.all
      @@metrics
    end

    def id
      self.class.to_s.demodulize.underscore.dasherize
    end

    def to_s
      id.titleize
    end

    def to_proc
      self.class.to_sym.to_proc
    end

    def self.name
      self.to_s.demodulize.titleize
    end

    def self.model_name
      ActiveModel::Name.new(Metrics::Metric)
    end

    def self.id
      self.to_sym
    end

    def to_param
      id
    end

    def self.to_sym
      self.to_s.demodulize.underscore.dasherize.to_sym
    end

    def self.display_name
      self.name
    end

    def self.description
    end

    def self.words(text)
      text.scan(/\S+/).map do |word|
        word.split(@stripper)[1]
      end.compact
    end

    def words(text)
      text.scan(/\S+/).map do |word|
        word.split(/(\p{Letter}.*\p{Letter})/)[1]
      end.compact
    end

    def analysis
    end

    ## Skip null fields and fields with whitespace strings
    #
    # Checks +value+ whether it is a null-valued field. A string is also null
    # if it contains only whitespace.
    # 
    def skip?(value)
      value.nil? or (value.is_a?(String) and value !~ /[^[:space:]]/)
    end

    def self.normalize?
      false
    end

    ## Keeps track of metric subclasses
    #
    # This method is called everytime a subclass of +Metrics::Metric+ is
    # created and adds the subclass to the list of metrics.
    #
    def self.inherited(subclass)
      super
      @@metrics ||= []
      @@metrics << subclass.instance
    end

    ##
    # Retrieves a value fromm the record based on the provided accessor path.
    #
    # Used by metrics that need to retrieve values from a specified set of
    # fields. For instance the Spelling and Richness of Information metric.
    #
    def self.value(record, accessors)
      accessors.inject(record) do |value, accessor|
        if value.is_a?(Array)
          if accessor.is_a?(Fixnum)
            value[accessor]
          else
            value.map { |item| item[accessor] unless item.nil? }
          end
        else
          value[accessor] unless value.nil?
        end
      end
    end

  end
end
