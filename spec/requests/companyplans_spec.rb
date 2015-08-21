require 'rails_helper'

RSpec.describe "Companyplans", type: :request do
  describe "GET /companyplans" do
    it "works! (now write some real specs)" do
      get companyplans_path
      expect(response).to have_http_status(200)
    end
  end
end
