describe ApplicationController, type: :controller do
  # describe 'CoinRPC::ConnectionRefusedError handling' do
  describe 'CoinAPI::ConnectionRefusedError handling' do
    controller do
      def index
        # raise CoinRPC::ConnectionRefusedError
        raise CoinAPI::ConnectionRefusedError
      end
    end

    it 'renders errors/connection' do
      get :index
      expect(response).to render_template 'errors/connection'
    end
  end
end
