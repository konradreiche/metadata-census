require 'spec_helper'

describe "shared dropdown menu partial" do

  it "displays the repository menu for repositories and snapshots" do
    repositories = FactoryGirl.create_list(:repositories, 3, :with_snapshots)
    repository = repositories.first
    snapshot = repository.snapshots.first

    locals = { entities: [repositories, snapshot], display: repository }
    rendered = render partial: 'shared/dropdown_menu', locals: locals

    expect(rendered).to have_selector('a[data-toggle]', repository.to_s)
    repositories.each do |entity|
      path = repository_snapshot_path(entity, snapshot)
      expect(rendered).to have_link(entity.to_s, href: path)
    end
  end

  it "displays the snapshots menu for repositories and snapshots" do
    repositories = FactoryGirl.create_list(:repositories, 3, :with_snapshots)
    repository = repositories.first

    snapshots = repository.snapshots.to_a
    snapshot = snapshots.first

    locals = { entities: [repository, snapshots], display: snapshot }
    rendered = render partial: 'shared/dropdown_menu', locals: locals

    expect(rendered).to have_selector('a[data-toggle]', snapshot.to_s)
    snapshots.each do |entity|
      path = repository_snapshot_path(repository, entity)
      expect(rendered).to have_link(entity.to_s, href: path)
    end
  end

end
