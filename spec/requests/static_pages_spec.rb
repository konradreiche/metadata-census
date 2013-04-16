require 'spec_helper'

describe "StaticPages" do

  describe "Home Page" do

    it "should have the content 'Welcome!'" do
      visit '/static_pages/home'
      page.should have_selector('p', :text => 'Welcome!')
    end

    it "should have the right title" do
      visit '/static_pages/home'
      page.should have_selector('title', :text => "Metadata Census | Home")
    end
  end
end
