require 'rails_helper'

RSpec.describe "companyplans/new", type: :view do
  before(:each) do
    assign(:companyplan, Companyplan.new())
  end

  it "renders new companyplan form" do
    render

    assert_select "form[action=?][method=?]", companyplans_path, "post" do
    end
  end
end
