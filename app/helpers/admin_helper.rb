module AdminHelper

  def create_bar(metric, type)
    tag(:div, class: "#{metric} #{type} bar")
  end

end
