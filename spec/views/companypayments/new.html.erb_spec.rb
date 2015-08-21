require 'rails_helper'

RSpec.describe "companypayments/new", type: :view do
  before(:each) do
    assign(:companypayment, Companypayment.new())
  end

  it "renders new companypayment form" do
    render

    assert_select "form[action=?][method=?]", companypayments_path, "post" do
    end
  end
end
