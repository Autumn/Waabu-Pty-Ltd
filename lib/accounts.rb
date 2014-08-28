require 'couchrest'
require 'rest-client'
require 'json'
require 'securerandom'
require 'digest/sha2'

module Waabu
  class Accounts

    DB = CouchRest.database! "#{Waabu::DB_SERVER}/#{ACCOUNTS_DB}"

    #DB = CouchRest.database! "http://172.24.0.7:5984/devel_accounts"

    def self.bootstrap_db 
      search = {
        "email" => {"map"=>"function(doc){if(doc.email){emit(doc.email,doc);}}"},
      }

      view = {"_id"=>"_design/search", "views"=>search}

      DB.save_doc view
    end

    def self.clean_db
      DB.get("_all_docs")["rows"].each do |row|
        DB.delete_doc({"_id"=>row["id"], "_rev"=>row["value"]["rev"]})
      end
    end

    def self.search_user email
      users = DB.view('search/email')["rows"]
      users.each do |user|
        return true if user["key"] == email
      end
      return false
    end

    def self.get_details email
      DB.view('search/email')["rows"].each do |user|
        return user["value"] if user["key"] == email
      end
      return {:error => "user not found"}
    end

    def self.register_user email, password
      salt = self.get_salt
      hash = self.hash_password password, salt
      DB.save_doc({:email => email, :hash => hash, :salt => salt})
      Waabu::Log.info "#{email} registered an account"
      Waabu::Email.welcome_mail email
    end

    def self.get_salt
      SecureRandom.random_number(8999999999999999) + 1000000000000000
    end

    def self.hash_password password, salt
      hash = Digest::SHA2.new << password
      salted_hash = salt.to_s + hash.to_s
      (Digest::SHA2.new << salted_hash).to_s
    end

    def self.authenticate_user email, password
      if (details = self.get_details email)[:error] != "user not found"
        if (self.hash_password(password, details["salt"]) == details["hash"]) then true else false end
      else
        false
      end
    end

    def self.update_password email, new_password
      new_salt = self.get_salt
      new_hash = self.hash_password new_password, new_salt
      user = self.get_details email
      doc = DB.get user["_id"]
      doc["hash"] = new_hash
      doc["salt"] = new_salt
      if DB.save_doc(doc)
        {:error => "none"}
      else
        {:error => "error occured"}
      end
    end

    def self.delete_account email, password
      if self.authenticate_user email, password
        # delte stuff
      end
    end

  end

end
