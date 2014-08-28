require 'sinatra'
require 'couchrest'
require 'json'

require_relative './lib/module.rb'

enable :sessions
set :sessions, :domain => '.waabu.com'
set :session_secret, "uguugao1"

set :protection, :origin_whitelist => ['https://waabu.com', 'https://www.waabu.com']

before do
  cache_control :private, :must_revalidate, :max_age => 0
  headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  headers['Access-Control-Allow-Origin'] = 'https://waabu.com'
  headers['Access-Control-Allow-Headers'] = 'accept, authorization, origin'
  headers['Access-Control-Allow-Credentials'] = 'true'
end

not_found do
  status 404
  erb :oops
end


$PRODUCTS_DB = CouchRest.database "http://172.24.0.7:5984/products_prod"
$PRODUCTS = []

def init
  $PRODUCTS_DB.view("search/id")["rows"].each do |row|
    $PRODUCTS.push row["value"] if not row["id"].match /^_design/
  end
end
init

get '/products' do
  $PRODUCTS.to_json
end

get '/paidbypaypal' do
  success = params["success"]
  payer_id = params["PayerID"]
  id = params["uuid"]
  token = params["token"]
  if success == "true" and payer_id and id and token
    execute = Waabu::Payment.execute_paypal_payment id, payer_id
    if execute[:error] == "none"
      erb :paid_success
    else 
      erb :paid_failure
    end
  else
    {:error => "invalid request"}.to_json
  end
end

get '/checkpayment' do
  puts "#{session[:login]} #{params[:id]}"
  if session[:login] == true && params[:id] 
    payment = Waabu::Payment.get_payment params[:id]
    puts "#{payment}"
     puts "#{session[:user]}"
    if payment != nil
      if payment["user"] == session[:user]
        {:state => payment["state"]}.to_json
      else
        {:error => "bad request"}.to_json
      end
    else
      {:error => "bad request"}.to_json
    end
  else
    {:error => "bad request"}.to_json
  end
end

post '/checkout' do
  
  # this is a filthy hack and it needs to be done properly
  # why doesn't sinatra set the cookie right, idk
  # angular sends cookie correctly, but session is not filled

  cookie = request.env["rack.session.unpacked_cookie_data"]
  session_id = cookie["session_id"]
  loggedin = cookie["login"]
  user = cookie["user"]
  session[:login] = loggedin
  session[:user] = user 
  session[:session_id] = session_id

  bitcoin = params[:bitcoin]
  paypal = params[:paypal]
  type = if bitcoin then "bitcoin" elsif paypal then "paypal" end

  if session[:login] == true and (bitcoin or paypal)
   cart = JSON.parse request.body.read
   data = Waabu::Payment.create_payment user, type, cart

   {:data => data}.to_json
  else
   {:error => "invalid request"}.to_json
  end

end

post '/login' do
  if params[:username] and params[:password]

    password = URI.decode params[:password]
    username = URI.decode params[:username]

    if Waabu::Accounts.authenticate_user username, password
      Waabu::Log.info "#{username} logged into store"
      session[:login] = true
      session[:user] = username
      {:success => true}.to_json
    else
      {:success => false}.to_json
    end
  end
end

post '/register' do
  if params[:username] and params[:password]
    # validate email address
    # url decode params

    password = URI.decode params[:password]
    username = URI.decode params[:username]

    if Waabu::Validator.validate_email(username) and not Waabu::Accounts.search_user(username)
      Waabu::Accounts.register_user username, password
      session[:user] = username
      session[:login] = true
      {:success => true}.to_json
    else
      {:success => false}.to_json
    end
  
  end
end

get '/loggedin' do
  if session[:login] 
    true.to_s
  else
    false.to_s
  end
end

get '/login' do
  session[:login] = true
end

get '/logout' do
  session.clear
end

get '/' do
  erb :index
end

get '/waabs' do
  ""
end

get '/config' do
  ""
end

get '/atcheckout' do
  ""
end

get '/features' do
  ""
end
