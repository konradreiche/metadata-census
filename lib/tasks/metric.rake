PATH = "app/models/metrics"

namespace :destroy do
  task :metric, [:name] => :environment do |t, args|
    name = args[:name].downcase
    FileUtils.rm("#{PATH}/#{name}.rb")

    Repository.all.each do |repository|
      repository.snapshots.each do |snapshot|
        snapshot.send("#{name}=", nil) if snapshot.respond_to?(name)
      end
    end
  end
end

namespace :generate do
  task :metric, [:name] => :environment do |t, args|
    name = args[:name].downcase

    Repository.all.each do |repository|
      repository.snapshots.each do |snapshot|
        snapshot.send("#{name}=", nil) if snapshot.respond_to?(name)
      end
    end

    template = File.read('lib/assets/metric_template.rb.erb')
    @class_name = name.camelcase

    metric_class = ERB.new(template).result
    File.open("#{PATH}/#{name}.rb", "w") do |file|
      file.write(metric_class)
    end
  end
end
