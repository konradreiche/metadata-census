module AdminHelper::RepositoriesHelper::SchedulerHelper

  def last_updated_date(metric)
    if not @repository[metric].nil?
      last_updated = DateTime.parse(@repository[metric][:last_updated])
      content_tag(:td, last_updated.strftime('%a %b %e %Y'), class: 'date')
    else
      content_tag(:td, 'N/A', class: 'date', rowspan: '2')
    end
  end

  def last_updated_time(metric)
    if not @repository[metric].nil?
      last_updated = DateTime.parse(@repository[metric][:last_updated])
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

end
