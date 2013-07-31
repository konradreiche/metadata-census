module AdminHelper

  def create_bar(metric, type)
    id = @repository.name.gsub('.', '-')
    tag(:div, class: "#{id} #{metric} #{type} bar")
  end

end
