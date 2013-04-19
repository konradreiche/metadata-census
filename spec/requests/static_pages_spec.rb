require 'spec_helper'

describe "StaticPages" do

  subject { page }

  describe "Home Page" do
    before { visit root_path }

    it { should have_selector 'p', text: 'Welcome!' }
    it { should have_selector 'title', text: full_title('') }
  end
end
