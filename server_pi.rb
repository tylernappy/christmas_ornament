require 'sinatra'
require 'httmultiparty'
require 'debugger'
require 'open-uri'

set :port, 4002
counter = 0

post "/" do
   # params = JSON.parse(request.body.read)
   puts "Processed image received"
   counter = params["counter"].to_i
   path = "/Users/tylernappy/Documents/photos/imagemagickimage_2_#{counter}.jpg"
   File.open(path, 'w') {|e| e.write( params["image"] ) } #saves image
   counter += 1
end
