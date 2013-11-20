module RepositoryManager
  extend ActiveSupport::Concern

  included do
    before_filter :repository, :snapshot, :repositories
  end

  def repository
    id = params[:repository_id] || params[:id]

    if id.nil?
      @repository = Repository.all.first
    else
      @repository = Repository.find(id)
    end

    gon.repository = @repository
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

      gon.snapshot = @snapshot
    end
  end

  def repositories
    @repositories = Rails.cache.fetch('repositories') { Repository.all.sort.to_a.reverse }
    gon.repositories = @repositories

    @repository_ranks = Rails.cache.fetch('repository_ranks') do
      scores = @repositories.map { |repository| repository.score }
      filtered = scores.compact.sort.uniq.reverse

      ranking = filtered.map { |score| filtered.index(score) + 1 }
      ranking += ['-'] * (scores.length - filtered.length)
      ranking
    end

    @numbers = Rails.cache.fetch('numbers') do
      @repositories.each_with_object({}) do |repository, numbers|
        snapshot = repository.snapshots.last
        next if snapshot.nil?
        numbers[repository] = snapshot.statistics
      end
    end

    @languages = Rails.cache.fetch('languages') do
      @repositories.each_with_object(Set.new) do |repository, languages|
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
      @repositories.each_with_object({}) do |repository, stats|
        snapshot = repository.snapshots.last
        stats[repository] = Hash.new
        stats[repository]['metadata_count'] = snapshot ? snapshot.metadata_records.count : 0
      end
    end
  end

end
