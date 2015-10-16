require 'rails_helper'

RSpec.describe "recurringinvoices/edit", type: :view do
  before(:each) do
    @recurringinvoice = assign(:recurringinvoice, Recurringinvoice.create!())
  end

  it "renders the edit recurringinvoice form" do
    render

    assert_select "form[action=?][method=?]", recurringinvoice_path(@recurringinvoice), "post" do
    end
  end
end
