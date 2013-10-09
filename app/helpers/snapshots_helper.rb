module SnapshotsHelper

  def create_metric_analysis_button(metric)
    options = { repository_id: @repository,
                snapshot_id: @snapshot.date,
                id: metric }

    icon = content_tag(:span, nil, class: 'glyphicon glyphicon-list-alt')
    path = repository_snapshot_metric_path(options)
    link_to icon, path, class: 'btn btn-default'
  end

  def weight(metric)
    metric = metric.to_s

    if session[:weightings][metric].nil?
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
