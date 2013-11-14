module RepositoriesHelper

  def count(repository)
    snapshot = repository.snapshots.last
    if snapshot.nil?
      '0'
    else
      number_with_delimiter(snapshot.metadata_records.count)
    end
  end

  def is_active?(page_name)
    "active" if params[:action] == page_name
  end

  def create_metric_analysis_link(metric)
    content_tag(:a, metric.to_s.titlecase, href: metric_url(metric))
  end

  ## Creates the URL to select the repository and metric
  #
  def metric_url(metric)
    "#{repository_url}/metric/#{metric.to_s.dasherize}"
  end

  ## Creates the URL to select the repository
  #
  def repository_url
    "/repository/#{@repository.name}"
  end

  ## Creates the metric selector for the breadcrumb navigation.
  #
  def analysis_metric_selector
    route = { controller: 'metrics', 
              action: 'show',
              metric: @metric.to_s }
    if current_page?(route)
      locals = { entities: Metrics::Metric.all,
                 link_text: @metric.to_s.titlecase,
                 link_method: :create_metric_analysis_link }

      content = render(partial: 'shared/dropdown_menu', locals: locals)
      content_tag(:li, content, class: 'metric selector')
    end
  end

  def repository_analysis_link(repository)
    href = "/repository/#{repository.name}"
    content_tag(:a, repository.name, href: href)
  end

  def record_parameters(i)
    record_identifier = Hash.new
    record_numbers = (0..1).to_a
    record_numbers.delete(i)
    record_numbers.each do |j|
      parameter = "record#{j + 1}".to_sym
      if params[parameter].nil?
        record = instance_variable_get("@#{parameter}")
        record_identifier[parameter] = record[:id]
      else
        record_identifier[parameter] = params[parameter]
      end
    end
    record_identifier
  end

  def iso639(language)
    return 'DUT' if language == 'Dutch'
    return 'SPA' if language == 'Spanish'
    return 'SPA' if language == 'Catalan'

    ISO_639.find_by_english_name(language).alpha3.upcase
  end

  def language_frequency(frequency)
    return '-' if frequency.nil?
    '%.2f' % (frequency * 100)
  end

  def score_cell(repository, score)
    classes = { 0..35 => 'bad', 36..79 => 'medium', 80..100 => 'good' }
    cls = classes.find { |r, _| r === score * 100 }.maybe.last
    content_tag(:td, '%.2f' % score, class: cls)
  end

end
