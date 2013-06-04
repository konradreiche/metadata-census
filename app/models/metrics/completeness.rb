module Metrics

  class Completeness < Metric
    attr_reader :fields, :fields_completed, :score

    def initialize(schema)
      @schema = schema
      @fields = count_fields(schema)
    end

    def compute(data)
      @fields_completed = count_completed_fields(data, @schema)
      @score = @fields_completed / @fields.to_f
    end

    def count_completed_fields(data, schema, stack=[])
      completed = 0
      schema.each do |attribute_name, attribute|
        case attribute_name
        when :properties
          completed += count_in_properties(data, schema, stack)
        when :items
          completed += count_in_items(data, schema, stack)
        end
      end
      completed
    end

    def count_in_properties(data, schema, fragments)

      completed = 0

      if data.is_a?(Hash)
        schema[:properties].each do |property_name, property_schema|

          # set default values in order to accredit the field as completed
          if property_schema[:default] and not data.has_key?(property) and not property_schema[:readonly]
            default = property_schema[:default]
            data[property] = (default.is_a?(Hash) ? default.clone : default)
          end
          if data.has_key?(property_name)
            completed += 1 if completed? data[property_name]
            count_completed_fields(data[property_name], property_schema, fragments)
          end
        end
      end
      completed
    end

    def count_in_items(data, schema, fragments)
      average = 0
      if data.is_a?(Array)
        if schema.is_a?(Hash) and not data.empty?
          sum = data.map do |item|
            count_completed_fields(item, schema[:items], fragments)
          end.inject(:+)
          average = sum / data.length.to_f
        elsif schema.is_a?(Array) and not data.empty?  # tuple validation
          sum = schema[:items].map.with_index do |item_schema, i|
            count_completed_fields(data[i], item_schema, fragments)
          end.inject(:+)
          average = sum / data.length.to_f
        end
      end
      average
    end

    def completed?(value)
      if value.nil?
        false
      elsif value.is_a? Numeric
        true
      elsif value.respond_to?(:empty?)
        not value.empty?
      else
        raise TypeError, "Unrecognized type"
      end
    end

    private
    def count_fields(schema, fields=0)
      schema[:properties].each do |property_name, property_schema|
        case property_schema[:type]
        when 'object'
          fields += count_fields(property_name)
        when 'array'
          fields += count_fields(property_schema[:items])
        else
          fields += 1
        end
      end if schema.has_key?(:properties)
      fields
    end

  end

end
