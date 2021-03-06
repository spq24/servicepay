Rails.application.routes.draw do

  resources :recurringinvoices

  root 'companies#new'


  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :companies do
      resources :company_steps, controller: 'companies/company_steps'
      collection do
        get :authenticate
        get :oauth_callback
      end
  end

  resources :users, only: [:index, :show]
  resources :payments
  resources :refunds
  resources :companypayments
  resources :companyplans
  resources :customers do
    resources :contacts
  end
  resources :reviews
  resources :invoices
  resources :items
  resources :coupons, except: [:edit, :update]
  resources :plans do
    resources :subscriptions, except: [:edit, :update]
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # You can have the root of your site routed with "root"
   

   get '/companies/:id/payment' => 'payments#new', as: 'payment_form'
   get '/companies/:id/payment/thank_you' => 'payments#thank_you', as: 'thank_you'
   get '/payments/:payment_id/refund/new' => 'refunds#new', as: "refund_payment"
   get '/payments/:id/happy' => 'reviews#happy', as: "happy_review"
   get '/payments/:id/okay' => 'reviews#okay', as: "okay_review"
   get '/payments/:id/sad' => 'reviews#sad', as: "sad_review"
   get '/companies/:id/review/thank-you-comments' => 'reviews#final', as: "final_review"
   get '/faq' => 'static_pages#faq'
   get '/tc' => 'static_pages#tc'
   get '/learn-more' => 'static_pages#learn'
   get '/vision' => 'static_pages#vision'
   get '/invoices/:id/customer-invoice' => 'invoices#customer_show', as: "customer_invoice"
   get 'companies/:id/companyplan/upgrade' => 'companyplans#upgrade', as: "companyplan_upgrade"
   mount StripeEvent::Engine => '/stripe_events'

end
