module Waabu

  SITE_URL = "https://devel.waabu.com"

  PAYPAL_MODE = "sandbox"
  PAYPAL_ID = "AfyLOBDeyD1bEkAQ0SWaTdmL2YLMWgSswhSQEUE-FlveYsjD2NiPSZg7dV5P"
  PAYPAL_SECRET = "ED6FThBnyHRDbz3ly7BD9GqoywV2miZ1l8O10B5vHJ2qjnjZ4hJ2vLLPXS2M"


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
