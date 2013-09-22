module AdminHelper

  def create_bar(metric, type)
    bar = { analyze: "progress-bar-success", compute: "progress-bar-info" }
    tag(:div, class: "progress-bar #{bar[type]} #{metric} #{type}")
  end

  def status(metric)
    snapshot = @repository.snapshots.last

    if snapshot.nil? || snapshot.send(metric).nil?
      tag(:strong, class: 'icon-remove')
    else
      tag(:strong, class: 'icon-ok')
    end
  end

end
