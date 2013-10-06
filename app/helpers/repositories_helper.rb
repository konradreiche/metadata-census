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

  def create_metric_analysis_button(metric)
    icon = content_tag(:span, nil, class: 'glyphicon glyphicon-list-alt')
    path = repository_metric_path(repository_id: @repository, id: metric)
    link_to icon, path, class: 'btn btn-default'
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
      locals = { entities: Metrics.all,
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
    record_numbers.each do |i|
      parameter = "record#{i + 1}".to_sym
      if params[parameter].nil?
        record = instance_variable_get("@#{parameter}")
        record_identifier[parameter] = record[:id]
      else
        record_identifier[parameter] = params[parameter]
      end
    end
    record_identifier
  end

  def repository_menu
    locals = { display: @repository.name,
               entities: @repositories,
               :parameter => :id,
               :path => :repository_path }

    partial = render partial: 'shared/dropdown_menu', locals: locals
    content_tag(:li, partial, class: 'repository selector')
  end

  def iso639(language)
    return 'DUT' if language == 'Dutch'
    return 'SPA' if language == 'Spanish'
    ISO_639.find_by_english_name(language).alpha3.upcase
  end

  def language_frequency(frequency)
    return '-' if frequency.nil?
    '%.2f' % (frequency * 100)
  end

end
