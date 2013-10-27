require 'spec_helper'

describe RepositoriesController do

  describe "GET index" do
    it "returns http success" do
      get 'index'
      response.should be_success
      expect(response).to render_template('index')
    end
  end

end
