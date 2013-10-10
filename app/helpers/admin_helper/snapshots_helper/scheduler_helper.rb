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
    locals = { display: @snapshot.date,
               entities: @repository.snapshots,
               :parameter => :snapshot_id,
               :path => :admin_repository_snapshot_scheduler_path }

    partial = render partial: 'shared/dropdown_menu', locals: locals
    content_tag(:li, partial, class: 'repository selector')
  end

end
