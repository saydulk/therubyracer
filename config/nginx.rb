server {
  listen 80;
  server_name www.cactoken.net;
}

server {
  listen 80;
  server_name cactoken.net;
}

server {
  server_name www.cactoken.net;

  root /home/deploy/mike/public;
  
  client_max_body_size 1024M;
  keepalive_timeout 1000;

  # Turn on Passenger
  passenger_enabled on;
  rails_env production;
}
