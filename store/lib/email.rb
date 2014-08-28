require 'mail'

module Waabu
  class Email
    def self.welcome_mail user    

text = <<EOF
Thanks for registering with Waabu Cloud Services. We're delighted to have you here, and we hope you enjoy using our services.

Your login username is #{user}

If you have any questions at all, feel free to send us an email at support@waabu.com and we'll get to you as soon as we can.

The Team at Waabu
EOF

      mail = Mail.new do
        to user
        from "no-reply@mail.waabu.com"
        subject "Welcome to Waabu Cloud Services"
        body text
      end
      self.send_mail mail

    end
 
    def self.account_creation_notification user
      
    end

    def self.payment_creation_notification user

    end

    def self.payment_complete_notification user

    end

    def self.spinup_complete_notification

    end

    def self.vmspinup_complete user, ipv4, ipv6, password
text = <<EOF
Your Waab is up and running! Here are the details:

IPv4 Address: #{ipv4}
IPv6 Address: #{ipv6}
Username: root
Password: #{password}

To access your Waab, just connect with an SSH client. From a Linux or Mac terminal, type the following command:

ssh root@#{ipv4}

When it asks you for your password, enter:

#{password}

If you're on Windows, we recommend PuTTY to connect. http://www.chiark.greenend.org.uk/~sgtatham/putty/

If you have any issues at all, send an email to support@waabu.com and we'll be with you in a flash.

The Team at Waabu
EOF

      mail = Mail.new do
        to user
        from "no-reply@mail.waabu.com"
        subject "Your Waab is up and running!"
        body text
      end

      self.send_mail mail
    end

  
    def self.send_mail mail
      puts "sending mail #{mail.to} #{mail.from}"
      mail.delivery_method :sendmail
      mail.deliver
    end 
  end
end
