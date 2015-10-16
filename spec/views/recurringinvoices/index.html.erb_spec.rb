require 'rails_helper'

RSpec.describe "recurringinvoices/index", type: :view do
  before(:each) do
    assign(:recurringinvoices, [
      Recurringinvoice.create!(),
      Recurringinvoice.create!()
    ])
  end

  it "renders a list of recurringinvoices" do
    render
  end
end
