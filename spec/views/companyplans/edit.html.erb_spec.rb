require 'rails_helper'

RSpec.describe "companyplans/edit", type: :view do
  before(:each) do
    @companyplan = assign(:companyplan, Companyplan.create!())
  end

  it "renders the edit companyplan form" do
    render

    assert_select "form[action=?][method=?]", companyplan_path(@companyplan), "post" do
    end
  end
end
