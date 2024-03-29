configure :development do
   set :database, {adapter: "sqlite3", database: "db/development.sqlite3"}
end

configure :production do
   db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')

   ActiveRecord::Base.establish_connection(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
   )
end
