require 'curb'
require 'oj'
require 'yaml'

OKD = 'is_okd_compliant'
OSI = 'is_osi_compliant'
LICENSE_FILE = 'data/licenses.json'

namespace :harvest do
  desc "Load licenses from all repositories and merge with current list"
  task :licenses, :file, :repository_file do |t, args|
    file = args.key?(:file) ? args[:file] : 'data/licenses.json'
    licenses = Oj.load(File.read(file))
    catalog = YAML.load(File.read('data/repositories/ckan.yml'))

    catalog['repositories'].each do |repository|
      url = repository['url']
      response = Oj.load(Curl.get(url + '/rest/licenses').body_str)

      remote_licenses = response.each_with_object({}) do |license, result|
        result[license['id']] = license
      end

      remote_licenses.each do |id, properties|
        if licenses.key?(id)
          licenses[OKD] = true if remote_licenses[OKD]
          licenses[OSI] = true if remote_licenses[OSI]
        else
          licenses[id] = remote_licenses[id]
        end
      end
    end

    File.open(LICENSE_FILE, 'w') { |f| f.write(JSON.pretty_generate(licenses)) }
  end
end
