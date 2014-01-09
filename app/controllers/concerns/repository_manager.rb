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
    jbuilder(__method__) unless @repository.nil?
  end

  def snapshot
    date = params[:snapshot_date] || params[:date]

    if not params[:repository_id].nil? and not date.nil?
      @snapshot = @repository.snapshots.where(date: date)

      if @snapshot.exists?
        @snapshot = @snapshot.first
      else
        @snapshot = @repository.snapshots.last
      end
    end
    jbuilder(__method__) unless @snapshot.nil?
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
        meta = result[repository] = Hash.new

        meta['metadata']   = snapshot.maybe.metadata_records.maybe.count
        meta['snapshots']  = repository.maybe.snapshots.maybe.count
        meta['rank']       = ranks[i]
        meta['score']      = repository.score
        meta['statistics'] = snapshot.maybe.statistics
      end
    end

    jbuilder(__method__)

    @numbers = Rails.cache.fetch('numbers') do
      @repositories.each_with_object({}) do |(repository, _), numbers|
        snapshot = repository.snapshots.last
        next if snapshot.nil?
        numbers[repository] = snapshot.statistics
      end
    end
  end

  def snapshots
  end

  private
  def jbuilder(entity)
    gon.jbuilder template: "app/views/jbuilder/#{entity}.json.jbuilder", controller: self
  end
end
