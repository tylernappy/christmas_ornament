require 'sinatra'
require 'httmultiparty'
require 'debugger'
require 'open-uri'
require 'mini_magick'
require 'twilio-ruby'
require 'dotenv'
require "aws/s3"
require 'active_record'
require 'sinatra/activerecord'
# require './environments'

set :port, 8084
# set :bind, '0.0.0.0'
counter = 0
c_height = 0.20 #image placing constant
shadow_offset = 4 #offset for shadow

Dotenv.load

set :database, {adapter: "sqlite3", database: "db/development.sqlite3"}

class ChristmasOrnament < Sinatra::Base
   register Sinatra::ActiveRecordExtension
end

class Member < ActiveRecord::Base
   has_many :photos, dependent: :destroy
end

class Photo < ActiveRecord::Base
   belongs_to :member
end

client = Twilio::REST::Client.new ENV['account_sid'], ENV['auth_token']

AWS::S3::Base.establish_connection!(
   :access_key_id     => ENV['AWS_ACCESS_KEY'],
   :secret_access_key => ENV['AWS_SECRET_KEY']
)

post "/" do
   # params = JSON.parse(request.body.read)
   puts "Image received from #{params['From']}"
   debugger
   debugger
   counter += 1
   path = "/Users/tylernappy/Documents/photos/imagemagickimage_1_#{counter}.jpg"
   member = Member.find_by_phone_number(params["To"])
   if !member.nil?
      if params["NumMedia"].to_i == 1

         ##Create image
         image = MiniMagick::Image.open(params["MediaUrl0"])
         image.combine_options do |c|
            c.font "Palatino-Roman"
            # c.font "#{ RAILS_ROOT}/public/images/fonts/georgia.ttf"
            c.gravity 'South'
            c.pointsize '100'
            c.draw "text 0,#{(image.height*c_height).to_i} \"#{params["Body"]}\""
            c.fill("#FFFFFF")
            c.draw "text #{shadow_offset},#{(image.height*c_height)+shadow_offset.to_i} \"#{params["Body"]}\""
            c.fill("blue")
         end
         image.write(path) #saves image with MiniMagick sytnax
         ##

         ##Save to AWS
         AWS::S3::S3Object.store(
            filename,
            open(path),
            # open(image), #use image instead so nothing is saved to server end memory
            ENV['BUCKET'],
            :access => :public_read
         )
         ##

         ##Save to ActiveRecord
         member.photos.create!({phone_number: params["From"], aws_url: "https://#{ENV['BUCKET']}.s3.amazonaws.com/#{filename}.jpg", confirmed: false})
         ##

         # response = HTTMultiParty.post("http://192.168.1.135:3000/", :query => {:image => File.binread(path), :counter => counter }) #reads image and POSTs to subsequent server
         # sends back the new image of what will be displayed on the image
         client.messages.create(
            from: params["To"],
            to: params["From"],
            body: "Thanks for your image and message!  Here is what it will look like on their ornament.  If you like it, send an *OK* to this number.  If not, resend another image and message!",
            media_url: "https://#{ENV['BUCKET']}.s3.amazonaws.com/#{filename}.jpg"
         )
      elsif  params["NumMedia"].to_i == 0 && params["Body"].downcase == "redo"

      elsif params["NumMedia"].to_i == 0 && params["Body"].downcase == "ok"
         #Do stuff if it sender wants it to be posted
         #Look up URL and ip address of pi
         photo = member.photos.find_by_phone_number(params["From"]).last
         res = HTTMultiParty.get(photo.aws_url) #get binary from image
         response = HTTMultiParty.post(member.ip, :query => {:image => res.parsed_response, :counter => counter })#post binary to raspberry pi
      else
         puts "No image sent try again"
         # sends error message to original sender
         client.messages.create(
            from: params["To"],
            to: params["From"],
            body: "Oops!  Looked like you didn't include an image.  In the same message, send both an image and a message you would like displayed on the image."
         )
      end
      # counter += 1
   else
      client.messages.create(
      from: params["To"],
      to: params["From"],
      body: "Oops! Looks like your friends eFrame is experiencing some technical difficulties. We will inform them of this."
      )
   end
end

def create_image url

end

# image = HTTMultiParty.get(params["MediaUrl0"])
# File.open("/Users/tylernappy/Documents/photos/test#{counter}.jpg", 'w') {|e| e.write(image.parsed_response) }
