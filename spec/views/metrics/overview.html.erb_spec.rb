require 'spec_helper'

describe "metrics/overview.html.erb" do

  it "should display the page" do

    render
    expect(rendered).to include 'Metrics'
  end
end
