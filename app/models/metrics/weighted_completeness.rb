module Metrics

  class WeightedCompleteness < Completeness

    def initialize(weight_file)
      super()
      @weights = YAML.load_file(weight_file).with_indifferent_access
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

    def check_properties(data, schema, fragments)
      if data.is_a?(Hash)
        schema[:properties].each do |property_name,property_schema|

          weight = weight(fragments + [property_name])
          @fields += weight

          # set default values in order to accredit the field as completed
          if property_schema[:default] and not data.has_key?(property) and not property_schema[:readonly]
            default = property_schema[:default]
            data[property] = (default.is_a?(Hash) ? default.clone : default)
          end

          if data.has_key?(property_name)
            @fields_completed += weight
            fragments << property_name
            compute(data[property_name], property_schema, fragments)
            fragments.pop
          end
        end
      end
    end
  end

end
