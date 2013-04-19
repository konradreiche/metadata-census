require 'spec_helper'

describe "StaticPages" do

  describe "Home Page" do

    it "should have the content 'Welcome!'" do
      visit root_path
      page.should have_selector('p', :text => 'Welcome!')
    end

    it "should not have a custom page title" do
      visit root_path
      page.should_not have_selector('title', :text => "| Home")
    end
  end
end
