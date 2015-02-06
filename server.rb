require 'sinatra'
require 'httmultiparty'
require 'debugger'
require 'open-uri'
require 'mini_magick'
require 'twilio-ruby'
require 'dotenv'

set :port, 8084
# set :bind, '0.0.0.0'
counter = 0
c_height = 0.20 #image placing constant
shadow_offset = 4 #offset for shadow

Dotenv.load

client = Twilio::REST::Client.new ENV['account_sid'], ENV['auth_token']

post "/" do
   # params = JSON.parse(request.body.read)
   puts "Image received from #{params['From']}"
   counter += 1
   path = "/Users/tylernappy/Documents/photos/imagemagickimage_1_#{counter}.jpg"
   if !params["MediaUrl0"].nil?
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
      ## Jason's part
      response = HTTMultiParty.post("http://192.168.1.135:3000/", :query => {:image => File.binread(path), :counter => counter }) #reads image and POSTs to subsequent server
      # sends back the new image of what will be displayed on the image
      client.messages.create(
         from: params["To"],
         to: params["From"],
         body: "Thanks for your image and message!  Here is what it will look like on their ornament:"
         # media_url: File.open(path)
      )
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
end

# image = HTTMultiParty.get(params["MediaUrl0"])
# File.open("/Users/tylernappy/Documents/photos/test#{counter}.jpg", 'w') {|e| e.write(image.parsed_response) }
