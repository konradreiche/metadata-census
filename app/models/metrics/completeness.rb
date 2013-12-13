module Metrics

  class Completeness < Metric

    attr_reader :fields, :fields_completed, :analysis

    def configure(schema)
      @schema = schema
      @fields = count_fields(schema)
      @analysis = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      super()
    end

    def self.description
      "Measures the completeness of a metadata record by counting the number of
      fields with a non-null value."
    end

    def compute(data)
      analysis = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      @fields_completed = count_completed_fields(data, @schema, analysis)

      score = @fields_completed / @fields.to_f
      return score, analysis
    end

    def count_completed_fields(data, schema, analysis, stack=[])
      completed = 0
      schema.each do |attribute_name, attribute|
        case attribute_name
        when 'properties'
          completed += count_in_properties(data, schema, analysis, stack)
        when 'items'
          completed += count_in_items(data, schema, analysis, stack)
        end
      end
      completed
    end

    def count_in_properties(data, schema, analysis, fragments)

      completed = 0

      if data.is_a?(Hash)
        schema['properties'].each do |property_name, property_schema|

          # set default values in order to accredit the field as completed
          if property_schema['default'] and not data.has_key?(property_name) and not property_schema['readonly']
            default = property_schema['default']
            data[property_name] = (default.is_a?(Hash) ? default.clone : default)
          end

          if data.has_key?(property_name)
            if ['object', 'array'].include? property_schema['type'].downcase
              completed += count_completed_fields(data[property_name], property_schema, analysis, fragments + [property_name])
            else

              analysis_field = fragments.inject(analysis) { |h, k| h[k] }
              global_analysis_field = fragments.inject(@analysis) { |h, k| h[k] }

              analysis_field[property_name] = 0 if analysis_field[property_name] == {}
              global_analysis_field[property_name] = 0 if global_analysis_field[property_name] == {}

              if completed?(data[property_name])
                completed += 1
                analysis_field[property_name] += 1
                global_analysis_field[property_name] += 1
              end

            end
          else
            fragments.inject(analysis) { |h, k| h[k] }[property_name] = 0
            fragments.inject(@analysis) { |h, k| h[k] }[property_name] = 0
          end

        end
      end
      completed
    end

    def count_in_items(data, schema, analysis, fragments)
      average = 0

      if data.is_a?(Array)

        if schema.is_a?(Hash) and not data.empty?
          sum = data.map do |item|
            count_completed_fields(item, schema['items'], analysis, fragments)
          end.inject(:+)

          average = sum / data.length.to_f

        elsif schema.is_a?(Array) and not data.empty?  # tuple validation

          sum = schema['items'].map.with_index do |item_schema, i|
            count_completed_fields(data[i], item_schema, analysis, fragments)
          end.reduce(:+)

          average = sum.fdiv(data.length)

        end
      end

      average
    end

    def completed?(value)
      if value.nil?
        false
      elsif value.is_a? Numeric
        true
      elsif value.is_a? Boolean
        true
      elsif value.respond_to?(:empty?)
        not value.empty?
      else
        raise TypeError, "Unrecognized type"
      end
    end

    private
    def count_fields(schema)
      fields = 0
      schema['properties'].each do |property_name, property_schema|
        case property_schema['type']
        when 'object'
          fields += count_fields(property_schema)
        when 'array'
          fields += count_fields(property_schema['items'])
        else
          fields += 1
        end
      end if schema.has_key?('properties')
      fields
    end

  end

end
