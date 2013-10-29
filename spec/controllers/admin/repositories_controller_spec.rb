require 'spec_helper'

describe Admin::RepositoriesController do

  describe "GET index" do
    it "renders the index template" do
      get "index"
      expect(response).to render_template("index")
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get "new"
      expect(response).to render_template("new")
    end
  end

  describe "POST create" do
    it "renders nothing" do
      post "create", file: "spec/data/repositories/test-repositories.yml"
      expect(response).to have_text(' ')
    end

    it "creates one new repository" do
      expect do
        post "create", file: "spec/data/repositories/test-repositories.yml"
      end.to change(Repository, :count).by(1)
    end

    it "creates the test repository" do
      post "create", file: "spec/data/repositories/test-repositories.yml"
      repository = Repository.all.first
      expect(repository.id).to eq("example.com")
    end
  end

end
