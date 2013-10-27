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
    it "stores the repositories in the database" do
    end
  end

end
