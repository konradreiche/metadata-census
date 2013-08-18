module RepositoriesHelper

  def is_active?(page_name)
    "active" if params[:action] == page_name
  end

  def create_metric_report_button(metric)
    icon = content_tag(:span, nil, class: 'glyphicon glyphicon-list-alt')
    content_tag(:a, icon, class: 'btn btn-default', href: metric_url(metric))
  end

  def create_metric_report_link(metric)
    content_tag(:a, metric.to_s.titlecase, href: metric_url(metric))
  end

  ## Creates the URL to select the repository and metric
  #
  def metric_url(metric)
    "#{repository_url}/#{metric.to_s.dasherize}"
  end

  ## Creates the URL to select the repository
  #
  def repository_url
    "/report/#{@repository.name}"
  end


  ## Creates the metric selector for the breadcrumb navigation.
  #
  def report_metric_selector
    locals = { entities: Metrics.list,
               link_text: @metric.to_s.titlecase,
               link_method: :create_metric_report_link }

    content = render(partial: 'shared/dropdown_menu', locals: locals)
    content_tag(:li, content, class: 'report metric selector')
  end

  ## Creates the repository selector for the breadcrumb navigation.
  #
  def report_repository_selector
    locals = { entities: @repositories,
               link_text: @repository.name,
               link_method: :repository_report_link }

    content = render(partial: 'shared/dropdown_menu', locals: locals)
    content_tag(:li, content, class: 'report repository selector')
  end

  def repository_report_link(repository)
    href = "/report/#{repository.name}"
    content_tag(:a, repository.name, href: href)
  end

  def record_parameters(i)
    record_identifier = Hash.new
    record_numbers = (0..1).to_a
    record_numbers.delete(i)
    record_numbers.each do |i|
      parameter = "record#{i + 1}".to_sym
      if params[parameter].nil?
        record = instance_variable_get("@#{parameter}")
        record_identifier[parameter] = record[:id]
      else
        record_identifier[parameter] = params[parameter]
      end
    end
    record_identifier
  end

end
