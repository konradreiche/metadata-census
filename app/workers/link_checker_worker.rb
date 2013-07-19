class LinkCheckerWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker
end

