module AdminHelper

  def create_bar(metric, type)
    bar = { analyze: "progress-bar-success", compute: "progress-bar-info" }
    tag(:div, class: "progress-bar #{bar[type]} #{metric} #{type}")
  end

  def status(metric)
    unless @repository.send(metric).nil?
      tag(:strong, class: 'icon-ok')
    else
      tag(:strong, class: 'icon-remove')
    end
  end

end
