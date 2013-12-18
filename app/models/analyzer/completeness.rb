module Analyzer

  class Completeness

    def self.analyze(snapshot, metric)
      scores = Generic.group_scores_by(snapshot, metric, %s(record.groups))
      schema_file = File.read('data/schema/ckan.json')

      schema = JSON.parse(schema_file).with_indifferent_access
      properties = fields(schema)

      fields_completed = flatten_hash(snapshot.completeness['analysis'])
      fields_completed = Hash[fields_completed.map { |k, v| [k.join("."), v] }]

      return { scores: scores, properties: properties,
               treemap: treemap(snapshot),
               fields_completed: fields_completed }
    end

    def self.treemap(snapshot)
      nodes = treemapper(snapshot.completeness['analysis'])
      return { 'name' => 'Completeness', 'children' => nodes }
    end

    def self.treemapper(hash)
      root = { 'name' => nil, 'children' => [] }
      leaf = { 'name' => nil, 'size' => 0 }

      hash.map do |key, value| 

        if value.is_a?(Hash)
          new_root = root.dup
          new_root['name'] = key
          new_root['children'] = treemapper(value)
          new_root
        else
          new_leaf = leaf.dup
          new_leaf['name'] = key
          new_leaf['size'] = value
          new_leaf
        end
      end
    end

    private
    def self.fields(schema)
      schema[:properties].map do |k, v|
        case v[:type]
        when "array"
          v[:items][:type] == "object" ? [k] + fields(v[:items]) : k
        when "object"
          v[:properties].nil? ? k : fields(v)
        else
          k
        end

      end.compact
    end

    # Flattens a hash
    def self.flatten_hash(hash, key = [])
      return { key  => hash } unless hash.is_a?(Hash)
      hash.inject({}) { |h, v| h.merge! flatten_hash(v[-1], key + [v[0]]) }
    end

  end

end
