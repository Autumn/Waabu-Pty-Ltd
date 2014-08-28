require 'mail'
require 'public_suffix'

module Waabu
  class Validator
    def self.validate_sshkey key
      tmp = Tempfile.new "key"
      tmp.write key
      tmp.rewind
      result = system "ssh-keygen -l -f #{tmp.path}"
      tmp.unlink
      tmp.close!
      result == true
    end

    def self.validate_email email
      addr = Mail::Address.new(email)
      PublicSuffix.valid?(addr.domain)
    end
 
    def self.validate_phone number
      
    end 

    def self.validate_address address

    end
  end
end
