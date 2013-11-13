require 'curb'
require 'oj'
require 'yaml'

OKD = 'is_okd_compliant'
OSI = 'is_osi_compliant'

namespace :fetch do
  desc "Load licenses from all repositories and merge with current list"
  task :licenses, :file, :repository_file do |t, args|
    file = args.key?(:file) ? args[:file] : 'data/licenses.json'
    licenses = Oj.load(File.read(file))
    catalog = YAML.load(File.read('data/repositories/ckan.yml'))

    catalog['repositories'].each do |repository|
      url = repository['url']
      remote_licenses = Oj.load(Curl.get(url + '/rest/licenses'))
      remote_licenses.each do |id, properties|
        if licenses.key?(id)
          licenses[OKD] = true if remote_licenses[OKD]
          licenses[OSI] = true if remote_licenses[OSI]
        else
          licenses[id] = remote_licenses[id]
        end
      end
    end

    File.new(file, 'w') { |f| Oj.dump(licenses, f) }
  end
end
