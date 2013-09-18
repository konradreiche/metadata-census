module AdminHelper

  def create_bar(metric, type)
    id = @repository.name.gsub('.', '-')
    tag(:div, class: "#{id} #{metric} #{type} progress-bar")
  end

  def create_button(metric)
    id = @repository.name.gsub('.', '-')
    classes = 'btn btn-default glyphicon glyphicon-cloud-upload schedule-metric-job'
    data = { metric: metric }
    tag(:button, class: classes, data: data)
  end

  def status(metric)
    unless @repository.send(metric).nil?
      tag(:strong, class: 'icon-ok')
    else
      tag(:strong, class: 'icon-remove')
    end
  end

end
