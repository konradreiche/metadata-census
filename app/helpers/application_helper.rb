module ApplicationHelper

  def create_navbar_button(display, path)
    cls = current_page?(path) ? 'active' : nil
    content_tag(:li, link_to(display, path), class: cls)
  end

end
