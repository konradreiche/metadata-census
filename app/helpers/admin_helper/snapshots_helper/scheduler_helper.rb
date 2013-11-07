module AdminHelper::SnapshotsHelper::SchedulerHelper

  def last_updated_date(metric)
    snapshot = @snapshot
    metric = snapshot.maybe(metric)

    if not metric.nil? and not metric[:last_updated].nil?
      last_updated = DateTime.parse(metric[:last_updated])
      content_tag(:td, last_updated.strftime('%a %b %e %Y'), class: 'date')
    else
      content_tag(:td, 'N/A', class: 'date', rowspan: '2')
    end
  end

  def last_updated_time(metric)
    snapshot = @snapshot
    metric = snapshot.maybe(metric)

    if not metric.nil? and not metric[:last_updated].nil?
      last_updated = DateTime.parse(metric[:last_updated])
      content_tag(:td, last_updated.strftime('%T'), class: 'time')
    end
  end

  def schedule_job_button(metric)
    classes = ['btn', 'btn-default']
    classes += ['glyphicon glyphicon-cloud-upload']
    classes += ['schedule-job', metric]

    data = { metric: metric }
    tag(:button, class: classes.join(' '), data: data)
  end

  def scheduler_snapshot_picker
    locals = { display: @snapshot.date, urls: {} }

    @repository.snapshots.each do |snapshot|
      parameters = { snapshot_id: snapshot.date }
      url = admin_repository_snapshot_scheduler_path(parameters)
      locals[:urls][snapshot.date] = url
    end

    partial = render partial: 'shared/entity_picker', locals: locals
    content_tag(:li, partial, class: 'repository selector')
  end

  def scheduler_repository_picker
    locals = { display: @repository.name, urls: {} }

    @repositories.each do |repository|
      next if repository.snapshots.empty?
      snapshot = repository.snapshots.where(date: @snapshot.date).first
      snapshot = repository.snapshots.first if snapshot.nil?

      parameter = { repository_id: repository.id, snapshot_id: snapshot.date }
      url = admin_repository_snapshot_scheduler_path(parameter)
      locals[:urls][repository.name] = url
    end

    partial = render partial: 'shared/entity_picker', locals: locals
    content_tag(:li, partial, class: 'repository selector')
  end

end
