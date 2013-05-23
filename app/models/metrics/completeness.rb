module Metrics

  class Completeness < Metric
    attr_reader :fields, :fields_completed

    @@processing = {
      :properties => :check_properties,
      :items      => :check_items
    }

    def initialize
      @fields = 0
      @fields_completed = 0
    end

    def score
      @fields_completed.to_f / @fields.to_f
    end

    def check_properties(data, schema, fragments=[])
      if data.is_a?(Hash)
        schema[:properties].each do |property_name,property_schema|

          @fields += 1
          # set default values in order to accredit the field as completed
          if property_schema[:default] and not data.has_key?(property) and not property_schema[:readonly]
            default = property_schema[:default]
            data[property] = (default.is_a?(Hash) ? default.clone : default)
          end

          if data.has_key?(property_name)
            @fields_completed += 1 
            compute(data[property_name], property_schema, fragments)
          end
        end
      end
    end

    def check_items(data, schema, fragments=[])
      if data.is_a?(Array)
        @fields_completed -= 1 if data.empty?
        if schema.is_a?(Hash)
          data.each do |item|
            compute(item, schema[:items], fragments)
          end
        elsif schema.is_a?(Array)  # tuple validation
          schema[:items].each_with_index do |item_schema,i|
            compute(data[i], item_schema, fragments)
          end
        end
      end
    end

    def compute(data, schema, fragments=[])
      schema.each do |attribute_name,attribute|
        applicable = @@processing.has_key?(attribute_name)
        send(@@processing[attribute_name], data, schema, fragments) if applicable
      end
    end
  end

end
