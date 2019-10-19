Rails.application.eager_load! if Rails.env.development?

class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

Peatio::Application.routes.draw do
  get 'bank_details/index'

  scope "(:locale)", locale: /en|zh|ko|/ do
    root 'posts#index'
  end

  get '/signin' => 'sessions#new', :as => :signin
  get '/about' => 'about#index', :as => :about
  get '/news' => 'news#index', :as => :news
  get '/support' => 'supports#index', :as => :supports
  get '/support/submit_info' => 'supports#info_page',:as => :info_page
  get '/terms' => 'terms#index', :as => :terms
  get '/privacy' => 'privacy#index', :as => :privacy
  get '/contact' => 'contact#index', :as => :contact
  get '/signup' => 'identities#new', :as => :signup
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure', :as => :failure
  # new route added by raman
  get '/welcome/activity_enj2' => 'welcome#activity_enj2', :as => :activity_enj2
  get '/welcome/activity_iotx' => 'welcome#activity_iotx', :as => :activity_iotx
  get '/welcome/vote' => 'welcome#vote', :as => :vote
  get '/welcome/activity_sky' => 'welcome#activity_sky', :as => :activity_sky
  get '/welcome/application_form' => 'welcome#application_form', :as => :application_form

  get '/email/verify' => 'token_expires#index', :as => :email_verify


  # new route added by raman
  match '/auth/:provider/callback' => 'sessions#create', via: [:get, :post]
  get '/sessions/:id/clear_session/' => 'sessions#clear_existing_session', :as => :clear_session
  resource :support
  resource :member, :only => [:edit, :update]
  get 'userCenter/balance' => 'members#balance_summary', :as=> :balance_summary
  resource :identity, :only => [:edit, :update]
  get '/google_verifies/:id' => 'google_verifies#new', :as => :google_verifies
  post '/auth_google_verifies/:id' => 'google_verifies#create', :as => :create_google_verifies

  namespace :authentications do
    resources :emails, only: [:new, :create]
    resources :identities, only: [:new, :create]
  end

  scope :constraints => { id: /[a-zA-Z0-9]{32}/ } do
    resources :reset_passwords
    resources :activations, only: [:new, :edit, :update]
    resources :two_factors, except: :destroy
  end

  resources :client_downloads , only: [:index]

  get '/documents/api_v2'
  get '/documents/websocket_api'

  scope module: :private do
    resources :bank_details
    # invite page referral
    match '/invite' => 'referral#invite', via: [:get, :post]
    resource  :id_document, only: [:edit, :update]

    resources :settings, only: :index do
      collection do
        post 'sms_authentication'
        post 'google_authentication'
        post :send_token_sms
        get  :add_details
        post :create_bank_info

      end
    end
    resources :api_tokens do
      member do
        delete :unbind
      end
    end

    resources :fund_sources, only: [:create, :update, :destroy]

    resources :funds, only: [:index] do
      collection do
        post :gen_address
      end
    end

    namespace :deposits do
      Deposit.descendants.each do |d|
        resources d.resource_name do
          collection do
            post :gen_address
          end unless d.resource_name.eql?('fiats')
        end
      end
    end

    namespace :withdraws do
      Withdraw.descendants.each do |w|
        resources w.resource_name
      end
    end

    resources :account_versions, :only => :index

    resources :exchange_assets, :controller => 'assets' do
      member do
        get :partial_tree
      end
    end

    get '/history/orders' => 'history#orders', as: :order_history
    get '/history/trades' => 'history#trades', as: :trade_history
    get '/history/account' => 'history#account', as: :account_history
    get '/history/download_csv' => 'history#download_csv', as: :download_csv_history
    get '/history/openOrders' => 'history#open_orders', as: :open_order_history

    get '/search/market' => 'markets#search', as: :search_market
    get '/show/market' => 'markets#show_all_markets', as: :show_all_markets
    get '/favorite/:id/:type' => 'markets#set_favorites'
    get '/market/prices' => 'markets#set_market_price'


    resources :markets, :only => :show, :constraints => MarketConstraint do
      resources :orders, :only => [:index, :destroy] do
        post :clear, on: :collection
      end
      resources :order_bids, :order_asks, :only => [:create] do
        post :clear, on: :collection
      end
    end

   post '/pusher/auth', to: 'pusher#auth'
  end

  scope ['', 'webhooks', ENV['WEBHOOKS_SECURE_URL_COMPONENT'].presence, ':ccy'].compact.join('/'), as: 'webhooks' do
    post 'tx_created', to: 'webhooks#tx_created'
    # post 'eth' => 'webhooks#eth'
  end

  draw :admin
  mount APIv2::Mount => APIv2::Mount::PREFIX

  namespace :test do
    resources :members, only: :index
  end unless Rails.env.production?


  get '/\*path' => redirect('/?goto=%{path}')
  match '*path' => redirect('/'), via: :get
end
