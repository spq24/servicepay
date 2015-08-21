require 'rails_helper'

RSpec.describe "companypayments/edit", type: :view do
  before(:each) do
    @companypayment = assign(:companypayment, Companypayment.create!())
  end

  it "renders the edit companypayment form" do
    render

    assert_select "form[action=?][method=?]", companypayment_path(@companypayment), "post" do
    end
  end
end
