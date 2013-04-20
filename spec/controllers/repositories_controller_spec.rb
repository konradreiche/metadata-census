require 'spec_helper'

describe RepositoriesController do

  describe "GET 'overview'" do
    it "returns http success" do
      get 'overview'
      response.should be_success
    end
  end

end
