require "rails_helper"

RSpec.describe CompanyplansController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/companyplans").to route_to("companyplans#index")
    end

    it "routes to #new" do
      expect(:get => "/companyplans/new").to route_to("companyplans#new")
    end

    it "routes to #show" do
      expect(:get => "/companyplans/1").to route_to("companyplans#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/companyplans/1/edit").to route_to("companyplans#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/companyplans").to route_to("companyplans#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/companyplans/1").to route_to("companyplans#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/companyplans/1").to route_to("companyplans#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/companyplans/1").to route_to("companyplans#destroy", :id => "1")
    end

  end
end
