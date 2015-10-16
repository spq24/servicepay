require 'rails_helper'

RSpec.describe "recurringinvoices/show", type: :view do
  before(:each) do
    @recurringinvoice = assign(:recurringinvoice, Recurringinvoice.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
