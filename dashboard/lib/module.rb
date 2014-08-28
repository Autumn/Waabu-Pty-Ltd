module Waabu 
  require 'json'

#  PAYPAL_MODE = "sandbox"
#  PAYPAL_ID = "AfyLOBDeyD1bEkAQ0SWaTdmL2YLMWgSswhSQEUE-FlveYsjD2NiPSZg7dV5P"
#  PAYPAL_SECRET = "ED6FThBnyHRDbz3ly7BD9GqoywV2miZ1l8O10B5vHJ2qjnjZ4hJ2vLLPXS2M"

  # load config file

  waabu_config = JSON.parse(open("/home/site/dashboard/prod.conf").read) or abort "requires waabu.conf"
  SITE_URL = waabu_config["site_url"] or abort "site url missing"
  PAYPAL_MODE = waabu_config["paypal_mode"] or abort "paypal mode missing"
  PAYPAL_ID = waabu_config["paypal_id"] or abort "paypal id missing"
  PAYPAL_SECRET = waabu_config["paypal_secret"] or abort "paypal secret missing"
  DB_SERVER = waabu_config["db_server"] or abort "db server missing"
  PRODUCTS_DB = waabu_config["products_db"] or abort "products db missing"
  ACCOUNTS_DB = waabu_config["accounts_db"] or abort "accounts db missing"
  PAYMENTS_DB = waabu_config["payments_db"] or abort "payments db missing"
  SUBSCRIPTIONS_DB = waabu_config["subscriptions_db"] or abort "subscriptions db missing"
  VM_DB = waabu_config["vm_db"] or abort "vm db missing"
  IP_DB = waabu_config["ip_db"] or abort "ip db missing"
  XEN_SERVER = waabu_config["xen_server"] or abort "xen server missing"


  require 'paypal-sdk-rest'
  require 'bitcoin'
  require 'rufus-scheduler'
  require 'rqrcode'
  require 'rqrcode_png'
  require 'ipaddress'
  require_relative 'logger.rb'
  require_relative 'accounts.rb'
  require_relative 'validator.rb'
  require_relative 'payment.rb'
  require_relative 'spinup.rb'
  require_relative 'email.rb'
  require_relative 'cart.rb'
  require_relative 'ip.rb'
  require_relative 'vmspinup.rb'
  require_relative 'vminspect.rb'
end
