require 'spec_helper'

describe "Repositories" do

  describe "GET /repositories" do
    it "displays repositories" do
      repository = FactoryGirl.create(:repository)
      visit repositories_path

      expect(page).to have_content("Repositories")
      expect(page).to have_content(repository.name)
      expect(page).to have_content(repository.type)

      all('table').first.click_link(repository.name)
      expect(page).to have_content('Repository')
    end

    it "links to single repository entities" do
      repository = FactoryGirl.create(:repository)
      visit repository_path(id: repository.id)

      expect(page).to have_content('Repository')
      expect(page).to have_content(repository.name)
    end
  end
end
