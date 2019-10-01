module APIv2
  module MobileApi
    class Favorites < Grape::API
      helpers ::APIv2::NamedParams

      before { authenticate! }

      desc 'To get favorites markets'
      get '/favorites' do
        favorites = current_user.favorites.map &:market_id
        present favorites: favorites, success: true
      end

      desc 'To mark favorite market for a specific user'
      params do
        use :market
      end
      post '/favorite' do
        Favorite.find_or_create_by(member_id: current_user.id, market_id: params[:market])
        favorites = current_user.favorites.map &:market_id
        present favorites: favorites, success: true, message: get_i18('favorites','favorite_added')
      end

      desc 'To delete favorite market for a specific user'
      params do
        use :market
        requires :placed_at, type: Integer, range: 0..Market.all.length, desc: 'Favorite market position- where you want to see it'
      end

      put '/favorite' do
        favorites = current_user.favorites.map &:market_id
        elem = favorites.delete(params[:market])
        favorites.insert(params[:placed_at].to_i, elem)
          current_user.favorites.destroy_all
        favorites.compact.each_with_index {|val, index| current_user.favorites.create(market_id: val, priority: index + 1)}
        present favorites: favorites.compact, success: true
      end

      desc 'To delete favorite market for a specific user'
      params do
        use :market
      end
      delete '/favorite' do
        favorite = Favorite.find_by(member_id: current_user.id, market_id: params[:market])
        favorite.destroy
        favorites = current_user.favorites.map &:market_id
        present favorites: favorites, success: true, message: get_i18('favorites','favorite_deleted')
      end


    end
  end
end