module ReportHelper

  def create_metric_report_link(metric)
    metric = Metrics::get_url_representation(metric)
    icon = tag(:strong, class: 'icon-th')
    url = "/report/metric?show=#{metric}&repository=#{@repository.name}"
    content_tag(:a, icon, class: 'btn', href: url)
  end

end
