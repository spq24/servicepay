require 'rails_helper'

RSpec.describe "Companypayments", type: :request do
  describe "GET /companypayments" do
    it "works! (now write some real specs)" do
      get companypayments_path
      expect(response).to have_http_status(200)
    end
  end
end
