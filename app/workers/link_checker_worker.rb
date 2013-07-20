class LinkCheckerWorker <  MetricsWorker

  def perform(repository_name)
    logger.info('Loading metadata')
    repository = Repository.find(repository_name)
    @metadata = repository.metadata
    logger.info('Preprocessing metadata')
    metric = Metrics::LinkChecker(@metadata, self)
    compute(repository, metric)
  end

end

