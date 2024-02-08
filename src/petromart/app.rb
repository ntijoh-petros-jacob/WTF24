class App < Sinatra::Base
    enable :sessions

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        redirect '/products'
    end

    get '/products' do
        @products = db.execute('SELECT * FROM products')
        erb :products
    end

    get '/products/add' do
        erb :additem
    end

    post '/products/add' do
        if params[:file]
            file = params[:file][:tempfile]
            image_url = params[:file][:filename]
            directory = File.join(settings.root, "public", "img")
            FileUtils.mkdir_p(directory) unless File.directory?(directory)
            File.open(File.join(directory, image_url), "wb") do |f|
              f.write(file.read)
            end
          else
            "No file uploaded"
          end

        name = params['name']
        desc = params['desc']
        price = params['price']
        image_url = params[:file][:filename]
        db.execute("INSERT INTO products (name, desc, price, image_url) VALUES (?,?,?,?)", [name, desc, price, image_url])
        redirect "/"
    end


    get '/products/:id' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        @comments = db.execute('SELECT * from products INNER JOIN comments ON products.id = comments.product_comment_id WHERE products.id = ?',id)    
        erb :overview
        
    end
    
end

