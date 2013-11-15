namespace :list do
  task :snapshots => :environment do
    repositories = Repository.where(:snapshots.exists => true)
    padding = repositories.map { |repository| repository.id.length }.max

    puts "--+-#{'-' * padding}-+-#{'-' * 10}"
    repositories.each do |repository|
      repository.snapshots.each_with_index do |snapshot, i|
        puts "#{i + 1} | #{repository.id.ljust(padding)} | #{snapshot.date}"
      end
    end
    puts "--+-#{'-' * padding}-+-#{'-' * 10}"
  end

end
