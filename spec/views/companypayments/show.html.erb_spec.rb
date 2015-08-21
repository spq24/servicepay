require 'rails_helper'

RSpec.describe "companypayments/show", type: :view do
  before(:each) do
    @companypayment = assign(:companypayment, Companypayment.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
