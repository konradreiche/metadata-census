module ReportHelper

  def create_metric_report_link(metric)
    metric = Metrics::get_url_representation(metric)
    icon = tag(:strong, class: 'icon-th')
    url = "/report/metric?show=#{metric}&repository=#{@repository.name}"
    content_tag(:a, icon, class: 'btn', href: url)
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
