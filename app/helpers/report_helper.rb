module ReportHelper

  def create_metric_report_button(metric)
    icon = tag(:strong, class: 'icon-th')
    content_tag(:a, icon, class: 'btn', href: metric_url(metric))
  end

  def create_metric_report_link(metric)
    content_tag(:a, metric.to_s.titlecase, href: metric_url(metric))
  end

  def metric_url(metric)
    metric = Metrics::get_url_representation(metric)
    "/report/metric?show=#{metric}&repository=#{@repository.name}"
  end

  def create_repository_link(repository)
    if @metric.nil?
      url = "?show=#{repository.name}"
    else
      url = "?show=#{@metric}&repository=#{repository.name}"
    end
    content_tag(:a, repository.name, href: url)
  end

end
