namespace :admin do
  get '/', to: 'dashboard#index', as: :dashboard
  get '/dashboard/dashboard_csv', to: 'dashboard#dashboard_csv', defaults: { format: 'csv' },  as: :csv_dashboard

  resources :id_documents, only: [:index, :show, :update] do
    get 'csv_download', on: :collection
  end

  resources :airdrops, only: %i(index create) do
    get :download_pdf, on: :collection
    member do
      get :send_token
      get :airdrop_history

    end
  end
  resource  :currency_deposit, only: [:new, :create]
  resources :proofs
  resources :notifications do
    post 'mark_as_read', on: :member
  end

  get "/activity" => "activities#index_activity", as: :activity
  get 'show_activity/:id' => "activities#show_activities", as: :show_activity
  get 'csv_activity' => "activities#csv_activity", as: :csv_activity
  get 'single_activity_download/:id' => "activities#single_activity_download", as: :single_activity_download
  resources :members, only: [:index, :show] do
    get 'commission', on: :collection
    get 'liquidity', on: :collection
    member do
      post :active
      post :toggle
    end
  end

  namespace :deposits do
    Deposit.descendants.each do |d|
      resources d.resource_name unless d.resource_name.eql?('fiats')
    end
    get '/csv_deposit' => 'coins#csv_deposit', as: :csv_deposit
  end

  namespace :withdraws do
    Withdraw.descendants.each do |w|
      resources w.resource_name
    end
    get '/email_send' => 'coins#withdraw_rejected_mail', as: :email_send
    get '/csv_withdraw' => 'coins#csv_withdraw', as: :csv_withdraw
  end

  namespace :statistic do
    resource :members, :only => :show
    resource :orders, :only => :show
    resource :trades, :only => :show
    resource :deposits, :only => :show
    resource :withdraws, :only => :show
  end

  resources :wallets, except: %i[edit destroy] do
    post :show_client_info, on: :collection
  end
  get '/transfer' => 'transfers#transfer_amount', as: :transfer
  get '/transfer/verify_auth' => 'transfers#verify_auth', as: :verify_auth
  get '/withdrawl_amount' => 'transfers#withdrawl_amount', as: :withdrawl

  resources :commissions
  resources :referrals do
    patch 'active', on: :collection
  end

end
