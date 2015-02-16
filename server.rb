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

set :port, 8085
# set :bind, '0.0.0.0'
counter = 0
$c_height = 0.20 #image placing constant
$shadow_offset = 4 #offset for shadow

Dotenv.load

set :database, {adapter: "sqlite3", database: "db/development.sqlite3"}

class ChristmasOrnament < Sinatra::Base
   register Sinatra::ActiveRecordExtension
end

class Member < ActiveRecord::Base
   has_many :original_photos, dependent: :destroy
end

class OriginalPhoto < ActiveRecord::Base
   belongs_to :member
   has_many :generated_photos
end

class GeneratedPhoto < ActiveRecord::Base
   belongs_to :original_photo
end

client = Twilio::REST::Client.new ENV['account_sid'], ENV['auth_token']

AWS::S3::Base.establish_connection!(
   :access_key_id     => ENV['AWS_ACCESS_KEY'],
   :secret_access_key => ENV['AWS_SECRET_KEY']
)

post "/" do
   # params = JSON.parse(request.body.read)
   # debugger
   puts "Text received from #{params['From']}"
   counter += 1
   path = "/Users/tylernappy/Documents/photos/imagemagickimage_1_#{counter}.jpg"
   member = Member.find_by_phone_number(params["To"])
   if !member.nil?
      if params["NumMedia"].to_i == 1
         puts "Image detected"
         ##Store original image
         res = HTTMultiParty.get(params["MediaUrl0"])
         bin_key = generate_random_string
         filename = "#{member.id}_#{bin_key}.jpg"
         original_photo = member.original_photos.create({phone_number: params["From"], aws_url: "https://#{ENV['BUCKET']}.s3.amazonaws.com/#{filename}", body: params["Body"]})
         AWS::S3::S3Object.store(filename, res.parsed_response, ENV['BUCKET'], :access => :public_read)

         ##Generate image
         image = generate_image(params["MediaUrl0"], params["Body"], original_photo.generated_photos.count)
         bin_key = generate_random_string
         filename = "#{member.id}_#{bin_key}.jpg"
         generated_photo = original_photo.generated_photos.create({aws_url: "https://#{ENV['BUCKET']}.s3.amazonaws.com/#{filename}", confirmed: false})
         AWS::S3::S3Object.store(filename, File.binread(image.path), ENV['BUCKET'], :access => :public_read)

         puts "Begin sending generated image..."
         client.messages.create(
            from: member.phone_number,
            to: params["From"],
            body: "Thanks for your image and message!  Here is what it will look like on their ornament.  If you like it, send an OK to this number. If you want it redone, send a REDO to this number.",
            media_url: generated_photo.aws_url
         )
         puts "Sent generated image"
      elsif  params["NumMedia"].to_i == 0 && params["Body"].downcase == "redo"
         puts "REDO detected"
         original_photo = member.original_photos.where(phone_number: params["From"]).last
         ##Generate image
         image = generate_image(original_photo.aws_url, original_photo.body,  original_photo.generated_photos.count)
         bin_key = generate_random_string
         filename = "#{member.id}_#{bin_key}.jpg"
         generated_photo = original_photo.generated_photos.create({aws_url: "https://#{ENV['BUCKET']}.s3.amazonaws.com/#{filename}", confirmed: false})
         AWS::S3::S3Object.store(filename, File.binread(image.path), ENV['BUCKET'], :access => :public_read)
         puts "Begin sending generated image..."
         client.messages.create(
            from: member.phone_number,
            to: params["From"],
            body: "Here is your redone image!  If you like this one, text OK to this number. If you want it redone, send a REDO to this number.",
            media_url: generated_photo.aws_url
         )
         puts "Sent generated image"
      elsif params["NumMedia"].to_i == 0 && params["Body"].downcase == "ok"
         puts "OK detected"
         #Do stuff if it sender wants it to be posted
         #Look up URL and ip address of pi
         generated_photo = member.original_photos.where(phone_number: params["From"]).last.generated_photos.last
         generated_photo.update_attributes!(confirmed: true)
         res = HTTMultiParty.get(generated_photo.aws_url) #get binary from image
         puts "Begin sending generated image..."
         client.messages.create(
            from: member.phone_number,
            to: params["From"],
            body: "This is the photo that will be displayed on your friends ornament. Thanks for texting in!",
            media_url: generated_photo.aws_url
         )
         puts "Sent generated image"
         puts "beginning POST request..."
         response = HTTMultiParty.post("http://#{member.ip}:3000", :query => {:image => res.parsed_response, :counter => counter })#post binary to raspberry pi
         puts "Finished POST request."
      else
         puts "No image sent. Try again"
         # sends error message to original sender
         puts "Begin sending message image..."
         client.messages.create(
            from: params["To"],
            to: params["From"],
            body: "Oops!  Looked like you didn't include an image.  In the same message, send both an image and a message you would like displayed on the image."
         )
         puts "Sent message"
      end
   else
      client.messages.create(
      from: params["To"],
      to: params["From"],
      body: "Oops! Looks like your friends eFrame is experiencing some technical difficulties. We will inform them of this."
      )
   end
end

def generate_image url, body, count
   image = MiniMagick::Image.open(url)
   image.combine_options do |c|
      c.font "Palatino-Roman"
      # c.font "#{ RAILS_ROOT}/public/images/fonts/georgia.ttf"
      c.gravity 'South'
      c.pointsize '100'
      c.draw "text 0,#{(image.height*$c_height).to_i} \"#{body}\""
      c.fill("#FFFFFF")
      c.draw "text #{$shadow_offset},#{(image.height*$c_height)+$shadow_offset.to_i} \"#{body}:#{count}\""
      c.fill("blue")
   end
   return image
end

def generate_random_string
   o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
   bin_key = (0...20).map { o[rand(o.length)] }.join
   return bin_key
end

def save_it_all (image_bytes)
   bin_key = generate_random_string
   filename = "#{member.id}_#{bin_key}.jpg"
   original_photo.generated_photos.create!({aws_url: "https://#{ENV['BUCKET']}.s3.amazonaws.com/#{filename}", confirmed: false})
   AWS::S3::S3Object.store(filename, bytes, ENV['BUCKET'], :access => :public_read)
end
# image = HTTMultiParty.get(params["MediaUrl0"])
# File.open("/Users/tylernappy/Documents/photos/test#{counter}.jpg", 'w') {|e| e.write(image.parsed_response) }

# AWS::S3::Bucket.find("ornament")
