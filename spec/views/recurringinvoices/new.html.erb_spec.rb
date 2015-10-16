require 'rails_helper'

RSpec.describe "recurringinvoices/new", type: :view do
  before(:each) do
    assign(:recurringinvoice, Recurringinvoice.new())
  end

  it "renders new recurringinvoice form" do
    render

    assert_select "form[action=?][method=?]", recurringinvoices_path, "post" do
    end
  end
end
