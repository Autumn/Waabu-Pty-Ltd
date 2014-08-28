require 'sinatra'

require 'json'
#require './lib/accounts.rb'
#require './lib/vm-query.rb'

require_relative './lib/module.rb'

set :protection, :origin_whitelist => ['https://dashboard.waabu.com', 'https://www.dashboard.waabu.com']

set :public_folder, Proc.new { File.join(root, "static") }
set :port, 4568

enable :sessions
set :sessions, :domain => ".waabu.com"
set :session_secret, "uguugao1"

get '/' do
puts "#{session}"
  if session[:login] == nil
    erb :login
  else
    erb :index
  end
end

get '/register' do 
  if session[:login] == nil
    erb :register
  else
    erb :index
  end
end

get '/sessionerror' do
  session.clear
  erb :sessionerror
end

get '/goodbye' do 
  session.clear
  erb :goodbye
end

post '/changepw' do
  if session[:login] == true
    if Waabu::Accounts.authenticate_user session[:user], params[:old]
      Waabu::Accounts.update_password(session[:user], params[:new]).to_json
    else
      {:error => "incorrect old pw"}.to_json
    end
  else
    {:error => "not logged in"}.to_json
  end
end

post '/deleteaccount' do 
  if session[:login] == true
    if Waabu::Accounts.authenticate_user session[:user], params[:pw]
      Thread.new {
        Waabu::Accounts.delete_account session[:user], params[:pw]
      }
      {:error => "none"}.to_json
    else
      {:error => "incorrect pw"}.to_json
    end   
  else 
    {:error => "not logged in"}.to_json
  end
end

#post '/support' do
#  if session[:login] == true
#    if params["subject"] != nil and params["body"] != nil
#      `ssh -i ~/.ssh/id_email root@103.228.135.246 ruby support.rb --email #{session[:user]} --subject '#{params["subject"]}' --body '#{params["body"]}'`
#       puts $?.exitstatus
#      # create email
#    else
#      puts "did nothing - fuck"
#    end
#  else
#    {"error"=>"not logged in"}.to_json
#  end
#end

#post '/feedback' do
#   puts "#{params}"
#   if session[:login] == true
#    if params["body"] != nil
#      # create email
#      `ssh -i ~/.ssh/id_email root@103.228.135.246 ruby feedback.rb --email '#{session[:user]}' --body '#{params["body"]}'`
#       puts $?.exitstatus
#    else
#
#      puts "did nothing - fuck"
#    end
#  else
#   puts "not logged in you're fucked"
#    {"error"=>"not logged in"}.to_json
#  end 
#end

get '/vms' do
  if session[:login] == true
    vms = Waabu::VMInspect.get_vms(session[:user])
    puts "#{vms}"
    vms.to_json
  else
    {"error"=>"not logged in"}.to_json
  end
end

get '/billing' do
  if session[:login] == true
    payments = Waabu::Payment.get_all_payments(session[:user])
    payments.to_json
  else
    {"error"=>"not logged in"}.to_json
  end
end

post '/query' do
  cookie = request.env["rack.session.unpacked_cookie_data"]

  session_id = cookie["session_id"]
  loggedin = cookie["login"]
  user = cookie["user"]

  session[:login] = loggedin
  session[:user] = user
  session[:session_id] = session_id

  if session[:login] == true
    return "error" if params[:type] == nil or params[:id] == nil
    if params[:type] == "cpu"
      Waabu::VMInspect.cpu_usage(params[:id]).to_json
    elsif params[:type] == "ram"
      Waabu::VMInspect.ram_usage(params[:id]).to_json
    elsif params[:type] == "powerstate"
      Waabu::VMInspect.power_state(params[:id]).to_json
    elsif params[:type] == "ip"
      Waabu::VMInspect.get_ip(params[:id]).to_json
    elsif params[:type] == "storage"
      Waabu::VMInspect.storage(params[:id]).to_json
    elsif params[:type] == "all"
      
      
      powerstate = Waabu::VMInspect.power_state(params[:id])
      storage = Waabu::VMInspect.storage(params[:id])
      ip = {}
      cpu = []
      if powerstate[:state] == "running"
      ram = Waabu::VMInspect.ram_usage(params[:id])
        ip = Waabu::VMInspect.get_ip(params[:id])
        cpu = Waabu::VMInspect.cpu_usage(params[:id])
      end
      {:cpu => cpu, :ram => ram, :power => powerstate, :ip => ip, :storage => storage}.to_json
    end
  else
    {"error"=>"not logged in"}.to_json
  end
end

post '/command' do
  if session[:login] == true
 
    if params[:type] == "reboot"
      res = Waabu::VMInspect.reboot_vm params[:id]
      puts res
    elsif params[:type] == "shutdown"
      res= Waabu::VMInspect.shutdown_vm params[:id]
      puts res
    elsif params[:type] == "start"
      res = Waabu::VMInspect.start_vm params[:id]
      puts res
    else
      {"error"=>"invalid command"}.to_json
    end
  else 
    {"error"=>"not logged in"}.to_json
  end 
end

post '/login' do
  puts "#{Marshal.dump(session.to_hash)}"
  puts "#{session[:login]}"
  if params[:email] == nil or params[:password] == nil
    erb :error
  else
    user = Waabu::Accounts.get_details params[:email]
    if user[:error] == nil
      if Waabu::Accounts.authenticate_user params[:email], params[:password]
 puts "session started"
        session[:login] = true
        session[:user] = params[:email]
        # initialise vm ids for querying
        #session[:vms] = ["386ef79b-7edb-f015-f58e-5e5c2123cef6","386ef79b-7edb-f015-f58e-5e5c2123cef6"]
        erb :success
      end 
    else
      erb :error
    end 
  end
end

get '/logout' do
  session.clear
  erb :logout
end
