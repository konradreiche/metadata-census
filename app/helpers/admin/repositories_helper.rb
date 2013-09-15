module Admin::RepositoriesHelper

  def import_link(file)
    content_tag(:a, 'Import', class: 'disabled import-link', data: { file: file }, href: '#' )
  end

end
