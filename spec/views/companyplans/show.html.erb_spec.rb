require 'rails_helper'

RSpec.describe "companyplans/show", type: :view do
  before(:each) do
    @companyplan = assign(:companyplan, Companyplan.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
