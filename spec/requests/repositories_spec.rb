require 'spec_helper'

describe "Repositories" do

  describe "GET /repositories" do
    it "displays repositories" do
      repository = FactoryGirl.create(:repository)
      visit repositories_path

      expect(page).to have_content("Repositories")
    end

    it "links to single repository entities" do
    end
  end
end
