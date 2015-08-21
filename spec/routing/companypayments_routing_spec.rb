require "rails_helper"

RSpec.describe CompanypaymentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/companypayments").to route_to("companypayments#index")
    end

    it "routes to #new" do
      expect(:get => "/companypayments/new").to route_to("companypayments#new")
    end

    it "routes to #show" do
      expect(:get => "/companypayments/1").to route_to("companypayments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/companypayments/1/edit").to route_to("companypayments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/companypayments").to route_to("companypayments#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/companypayments/1").to route_to("companypayments#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/companypayments/1").to route_to("companypayments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/companypayments/1").to route_to("companypayments#destroy", :id => "1")
    end

  end
end
