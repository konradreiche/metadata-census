module AdminHelper

  def create_bar(metric, type)
    id = @repository.name.gsub('.', '-')
    tag(:div, class: "#{id} #{metric} #{type} bar")
  end

  def create_button(metric)
    id = @repository.name.gsub('.', '-')
    icon = tag(:strong, class: 'icon-tasks')
    content_tag(:button, icon, class: "btn compute-metric #{id} #{metric}")
  end

  def status(metric)
    unless @repository.send(metric).nil?
      tag(:strong, class: 'icon-ok')
    else
      tag(:strong, class: 'icon-remove')
    end
  end

end
