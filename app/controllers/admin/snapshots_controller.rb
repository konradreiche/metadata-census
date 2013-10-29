require 'digest'
require 'oj'

class Admin::SnapshotsController < ApplicationController
  include RepositoryManager
  include MetricManager

  def create
    path = params[:file]
    snapshot = nil

    File.open(path) do |file|
      parse_metadata(file) do |parsed|

        case parsed
        when Hash
          attributes = filter_header(parsed)
          repository = Repository.find(parsed['repository'].downcase)
          snapshot = repository.snapshots.where(date: attributes['date'])

          if not snapshot.exists?
            snapshot = repository.snapshots.create!(attributes)
          else
            snapshot = snapshot.first
            snapshot.update_attributes!(attributes)
          end

        when Array
          parsed.map do |metadata|
            id = Digest::MD5.hexdigest(metadata["id"] + snapshot.id)
            attributes = { _id: id, record: metadata,
                           snapshot_id: snapshot.id,
                           statistics: { resources: metadata['resources'].length } }

            MetadataRecord.create!(attributes)
          end.each { |record| snapshot.metadata_records << record }
        else
          raise TypeError, "Unknown type #{parsed.class}"
        end
      end

      compile_statistics(snapshot)
      snapshot.save!
    end

    render nothing: true
  end

  def destroy
    @snapshot.delete
    render nothing: true
  end

  def parse_metadata(file)
    gz = Zlib::GzipReader.new(file)
    gz.each_line { |line| yield Oj.load(line) }
  end

  def filter_header(header)
    fields = Snapshot.fields.keys
    header.keys.inject({}) do |filtered, key|
      filtered[key] = header[key] if fields.include?(key)
      filtered
    end
  end

  def compile_statistics(snapshot)
    snapshot.statistics = Hash.new { |hash, key| hash[key] = Hash.new }
    logger.info('Compile resources')
    compile_resource_numbers(snapshot)
    logger.info('Compile languages')
    compile_languages(snapshot)
  end

  def compile_resource_numbers(snapshot)
    field = 'statistics.resources'
    criteria = MetadataRecord.where(snapshot: snapshot).asc(field)

    statistics = snapshot.statistics
    count = criteria.length

    statistics[:resources][:min] = criteria.min(field)
    statistics[:resources][:avg] = criteria.avg(field)
    statistics[:resources][:max] = criteria.max(field)

    statistics[:resources][:sum] = criteria.sum(field)
    statistics[:resources][:med] = criteria[count / 2][field]
  end

  def compile_languages(snapshot)
    analyzer = Analyzer::Languages.new
    snapshot.statistics[:languages] = analyzer.analyze(snapshot)
  end

  def compile_times(snapshot)
    times = Hash.new { |hash, date| hash[date] = [0, 0] }

    snapshot.metadata_records.each do |document|
      created = Date.parse(document.record['metadata_created']).to_s
      modified = Date.parse(document.record['metadata_modified']).to_s

      times[created] = [times[created][0] + 1, times[created][1]]
      times[modified] = [times[modified][0], times[modified][1] + 1]
    end
    snapshot.statistics[:times] = times
  end

  def status
    repository = @repository.id
    jobs = Job.where(repository: repository, snapshot: @snapshot.date.to_s)
  
    result = jobs.to_a.inject({}) do |status, job|
      status[job.metric] = Sidekiq::Status::get_all(job.sidekiq_id)
      percent = Sidekiq::Status::pct_complete(job.sidekiq_id)
      status[job.metric][:percent] = percent.finite? ? percent : 0.0
      status
    end

    render json: result
  end


end
