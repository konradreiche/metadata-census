module RepositoryManager
  extend ActiveSupport::Concern

  included do
    before_filter :repository, :snapshot, :repositories, :snapshots
  end

  def repository
    id = params[:repository_id] || params[:id]

    if id.nil?
      @repository = Repository.all.first
    else
      @repository = Repository.find(id)
    end
  end

  def snapshot
    date = params[:snapshot_id] || params[:id]

    if not params[:repository_id].nil? and not date.nil?
      @snapshot = @repository.snapshots.where(date: date)

      if @snapshot.exists?
        @snapshot = @snapshot.first
      else
        @snapshot = @repository.snapshots.last
      end
    end
  end

  def snapshots
  end

  def repositories
    @repositories = Rails.cache.fetch('repositories_with_snapshots') do
      repositories = Repository.all.to_a.sort
      scores = repositories.map { |r| r.score }.compact.sort.uniq.reverse

      ranks = scores.map { |score| scores.index(score) + 1 }
      ranks += [nil] * (repositories.length -  scores.length)

      repositories = repositories.reverse.each_with_object({})
      repositories.each_with_index do |(repository, result), i|
        snapshot = repository.snapshots.last
        result[repository] = { 'snapshots' => repository.snapshots.count,
                               'metadata'  => snapshot.metadata_records.count,
                               'rank'      => ranks[i] }
      end
    end

    gon.repositories = Rails.cache.fetch('repositories') do
      Repository.all.without(:snapshots).sort.to_a.reverse
    end

    @numbers = Rails.cache.fetch('numbers') do
      @repositories.each_with_object({}) do |(repository, _), numbers|
        snapshot = repository.snapshots.last
        next if snapshot.nil?
        numbers[repository] = snapshot.statistics
      end
    end

    @languages = Rails.cache.fetch('languages') do
      @repositories.each_with_object(Set.new) do |(repository, _), languages|
        snapshot = repository.snapshots.last
        next if snapshot.nil?
        languages_set = @numbers[repository]['languages']
        languages += languages_set.keys

        total = languages_set.values.sum
        languages_set.update(languages_set) { |language, count| count.fdiv(total) }
        languages_set
      end
    end

    @repository_stats = Rails.cache.fetch('repository_stats') do
      @repositories.each_with_object({}) do |(repository, _), stats|
        snapshot = repository.snapshots.last
        stats[repository] = Hash.new
        stats[repository]['metadata_count'] = snapshot ? snapshot.metadata_records.count : 0
      end
    end
  end

end
