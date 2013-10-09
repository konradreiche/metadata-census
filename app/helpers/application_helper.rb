module ApplicationHelper

  def navbar_button(display, path)
    cls = current_page?(path) ? 'active' : nil
    content_tag(:li, link_to(display, path), class: cls)
  end

  def repository_menu
    locals = { display: @repository.name,
               entities: @repositories,
               :parameter => :id,
               :path => :repository_path }

    partial = render partial: 'shared/dropdown_menu', locals: locals
    content_tag(:li, partial, class: 'repository selector')
  end

  def snapshot_menu
    locals = { display: @snapshot.date,
               entities: @repository.snapshots,
               :parameter => :id,
               :path => :repository_snapshot_path }

    partial = render partial: 'shared/dropdown_menu', locals: locals
    content_tag(:li, partial, class: 'repository selector')
  end

end
