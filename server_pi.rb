#REAL VERSION
require 'sinatra'
#require 'httmultiparty'

set :port, 3000
set :bind, '0.0.0.0'
counter = 0

post "/" do
   puts "processed image received"
   counter = params["counter"].to_i
   path = "./images/image#{counter}.jpg"
   File.open(path, 'w') {|e| e.write(params["image"])}
   `sudo fbi -T 2 -d /dev/fb1 -noverbose -a #{path}`
   #`sudo fbi -d /dev/fb0 -a -T 2 #{path}`
   puts "displaying image"
end

#get "/" do
# "hello from #{`uname -a`}"
#end

#post "/text_processor" do
# puts "got something"
# image = HTTMultiParty.get(params["MediaUrl0"])
# File.open("./images/image#{counter}.jpg", 'w'){|e| e.write(image.parsed_response) }
# `sudo fbi -d /dev/fb0 -a -T 2 ./images/image#{counter}.jpg`
# puts "looking at image#{counter}"
# counter += 1
#end



#MAC VERSION
# require 'sinatra'
# require 'httmultiparty'
# require 'debugger'
# require 'open-uri'
#
# set :port, 4002
# counter = 0
#
# post "/" do
#    # params = JSON.parse(request.body.read)
#    puts "Processed image received"
#    counter = params["counter"].to_i
#    path = "/Users/tylernappy/Documents/photos/imagemagickimage_2_#{counter}.jpg"
#    File.open(path, 'w') {|e| e.write( params["image"] ) } #saves image
#    counter += 1
# end
