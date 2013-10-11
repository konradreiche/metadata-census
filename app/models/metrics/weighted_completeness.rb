module Metrics

  class WeightedCompleteness < Completeness

    def initialize(schema, weight_file)
      @weights = YAML.load_file(weight_file).with_indifferent_access
      super(schema)
    end

    def weight(keys)
      keys.inject(@weights) do |hash, key|
        if hash[key].is_a?(Array)
          keys.last != key ? hash[key].last : hash[key].first
        else
          hash[key]
        end
      end
    end

    def count_in_properties(data, schema, analysis, stack)
      completed = 0
      if data.is_a?(Hash)
        schema['properties'].each do |property_name, property_schema|

          # set default values in order to accredit the field as completed
          if property_schema['default'] and not data.has_key?(property) and not property_schema['readonly']
            default = property_schema['default']
            data[property] = (default.is_a?(Hash) ? default.clone : default)
          end
          if data.has_key?(property_name)
            stack << property_name
            if ['object', 'array'].include? property_schema['type'].downcase
              completed += count_completed_fields(data[property_name], property_schema, analysis, stack)
            else
              completed += weight(stack) if completed? data[property_name]
            end
            stack.pop()
          end
        end
      end
      completed
    end

    private
    def count_fields(schema, stack=[])
      fields = 0
      schema['properties'].each do |property_name, property_schema|
        stack << property_name
        case property_schema['type']
        when 'object'
          fields += count_fields(property_schema, stack)
        when 'array'
          fields += count_fields(property_schema['items'], stack)
        else
          fields += weight(stack)
        end
        stack.pop()
      end if schema.has_key?('properties')
      fields
    end

  end

end
