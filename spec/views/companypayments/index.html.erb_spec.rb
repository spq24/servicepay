require 'rails_helper'

RSpec.describe "companypayments/index", type: :view do
  before(:each) do
    assign(:companypayments, [
      Companypayment.create!(),
      Companypayment.create!()
    ])
  end

  it "renders a list of companypayments" do
    render
  end
end
