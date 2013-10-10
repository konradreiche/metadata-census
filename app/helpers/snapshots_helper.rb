module SnapshotsHelper

  def create_metric_analysis_button(metric)
    options = { repository_id: @repository,
                snapshot_id: @snapshot.date,
                id: metric }

    icon = content_tag(:span, nil, class: 'glyphicon glyphicon-list-alt')
    path = repository_snapshot_metric_path(options)
    link_to icon, path, class: 'btn btn-default'
  end

  def last_updated(metric)
    metric = @snapshot.maybe(metric)

    if not metric.nil? and not metric['last_updated'].nil?
      last_updated = DateTime.parse(metric['last_updated'])

      date = last_updated.strftime('%a %b %e %Y')
      date_column = content_tag(:div, date, class: 'col-md-12')

      time = last_updated.strftime('%T')
      time_column = content_tag(:div, time, class: 'col-md-12')

      rowAbove = content_tag(:div, date_column, class: 'row')
      rowBelow = content_tag(:div, time_column, class: 'row')
      rowAbove << rowBelow 
    else
      'N/A'
    end
  end

  def weight(metric)
    metric = metric.to_s

    if session[:weightings].nil?
      1
    else
      session[:weightings][metric]
    end
  end

  def weighting_slider(metric)
    value = weight(metric)
    options = { type: 'range',
                class: 'weight-slider',
                min: 0,
                max: 10,
                step: 1,
                value: value,
                data: { metric: metric } }

    tag(:input, options)
  end

end
