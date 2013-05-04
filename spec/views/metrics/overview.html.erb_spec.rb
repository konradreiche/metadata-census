require 'spec_helper'

describe "metrics/overview.html.erb" do

  it "should display the page" do
    assign(:repositories, [
      stub_model(Repository, :name => 'data.gov.com', :type => 'CKAN',
                 :url => 'http://data.gov.com', :datasets => 100000,
                 :latitude => 0.0, :longitude => 0.0)
    ])
    render
    expect(rendered).to include 'Metrics'
  end
end
