namespace :list do

  task :snapshots do
    Mongoid.load!('config/mongoid.yml')
    Repository.each do |repository|
      puts "+-----------+"
      repository.snapshots.each_with_index do |snapshot, i|
      end
    end
  end

end
