require 'rails_helper'

RSpec.describe "companyplans/index", type: :view do
  before(:each) do
    assign(:companyplans, [
      Companyplan.create!(),
      Companyplan.create!()
    ])
  end

  it "renders a list of companyplans" do
    render
  end
end
