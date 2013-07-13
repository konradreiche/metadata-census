require 'spec_helper'

describe "repositories/overview.html.erb" do
  
  it "should display all the repositories" do
    assign(:repositories, [
      stub_model(Repository, :name => 'Open Data Portal', :type => 'Database',
                 :url => 'http://example.com/portal', :total => 3000),
      stub_model(Repository, :name => 'Open Government', :type => 'Platform',
                 :url => 'http://example.com/platform', :total => 7000)
    ])

    render

    expect(rendered).to include 'Open Data Portal'
    expect(rendered).to include 'Database'
    expect(rendered).to include 'example.com/portal'

    expect(rendered).to include 'Open Government'
    expect(rendered).to include 'Platform'
    expect(rendered).to include 'example.com/platform'

    expect(rendered).to include '3,000'
    expect(rendered).to include '7,000'
  end

end
