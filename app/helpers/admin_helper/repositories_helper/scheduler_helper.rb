module AdminHelper::RepositoriesHelper::SchedulerHelper

  def last_updated_date(metric)
    if not @repository[metric].nil?
      last_updated = DateTime.parse(@repository[metric][:last_updated])
      content_tag(:td, last_updated.strftime('%a %b %e %Y'))
    else
      content_tag(:td, 'N/A', rowspan: '2')
    end
  end

  def last_updated_time(metric)
    if not @repository[metric].nil?
      last_updated = DateTime.parse(@repository[metric][:last_updated])
      content_tag(:td, last_updated.strftime('%T'))
    end
  end

end
