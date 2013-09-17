module Admin::RepositoriesHelper

  def import_link(file)
    content_tag(:a, 'Import', class: 'import-link', data: { file: file }, href: '#' )
  end
  
  def import_metadata_link(repository, file)
    data = { file: file, repository: repository }
    content_tag(:a, 'Import', class: 'metadata-import-link', data: data , href: '#' )
  end

end
