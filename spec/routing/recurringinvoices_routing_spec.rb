require "rails_helper"

RSpec.describe RecurringinvoicesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/recurringinvoices").to route_to("recurringinvoices#index")
    end

    it "routes to #new" do
      expect(:get => "/recurringinvoices/new").to route_to("recurringinvoices#new")
    end

    it "routes to #show" do
      expect(:get => "/recurringinvoices/1").to route_to("recurringinvoices#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/recurringinvoices/1/edit").to route_to("recurringinvoices#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/recurringinvoices").to route_to("recurringinvoices#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/recurringinvoices/1").to route_to("recurringinvoices#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/recurringinvoices/1").to route_to("recurringinvoices#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/recurringinvoices/1").to route_to("recurringinvoices#destroy", :id => "1")
    end

  end
end
