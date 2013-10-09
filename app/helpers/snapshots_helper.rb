module SnapshotsHelper

  def create_metric_analysis_button(metric)
    options = { repository_id: @repository,
                snapshot_id: @snapshot.date,
                id: metric }

    icon = content_tag(:span, nil, class: 'glyphicon glyphicon-list-alt')
    path = repository_snapshot_metric_path(options)
    link_to icon, path, class: 'btn btn-default'
  end

end
