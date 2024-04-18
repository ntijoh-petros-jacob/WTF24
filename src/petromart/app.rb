class App < Sinatra::Base
    enable :sessions

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    helpers do
        def h(text)
          Rack::Utils.escape_html(text)
        end
      
        def hattr(text)
          Rack::Utils.escape_path(text)
        end
    end


    before do 
        if session[:user_id]
            @user = db.execute('SELECT * FROM users WHERE id = ?', session[:user_id]).first
            cart_items = db.execute('SELECT * FROM carts WHERE user_id = ?', session[:user_id])
            
            @cart = []
            
            cart_items.each do |item|
                @cart << item["product_id"]
            end

        end
    end

  

    get '/' do
        redirect '/products'
    end

    get '/products' do

        @products = db.execute('SELECT * FROM products')
        erb :'products/index'
    end

    get '/products/add' do
        erb :'products/new'
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
        @product_tags = db.execute('SELECT * FROM products JOIN product_tags ON products.id = product_tags.product_id JOIN tags ON product_tags.tag_id = tags.id WHERE products.id = ?',id)
        erb :'products/show'
        
    end

    post '/products/:id' do |id|
        @id = id
        db.execute("INSERT INTO comments (content, commentor, product_comment_id) VALUES (?,?,?)", [h(params['comment']), @user['username'], id])
        redirect "/products/#{id}"
    end


    get '/login' do
        erb :'users/login'
    end
    post '/login' do
        user = db.execute('SELECT * FROM users WHERE username = ?', params['username']).first


        if user
            if BCrypt::Password.new(user['hashed_pass']) == (params['password'].chomp)
                puts "Password matches!"
                session[:user_id] = user['id']
                if user['access_level'] == 2
                end
                redirect '/products'
            else
                puts "Password does not match!"
                redirect '/login'
            end
        else
            puts "User not found!"
            redirect '/login'
        end
    end     
    
    get '/logout' do
        session.destroy
        redirect '/products'
    end        

    get '/register' do
        erb :'users/new'
    end

    post '/register' do
        user_check = db.execute('SELECT * FROM users WHERE username = ?', params['username'])
        p user_check
        if user_check == []
            hashed_pass = BCrypt::Password.create("#{params['cleartext_password'].to_s.chomp}") 
            db.execute('INSERT INTO users (username, hashed_pass, access_level) VALUES (?,?,?)', params['username'], hashed_pass, 1)
            redirect '/login'
        else
            puts "användarnamnet är upptaget yäni"
            redirect '/register'
        end
    end
    
    post '/cart/:id' do |id|
        
    end

    get '/cart' do
        @cart = db.execute('SELECT * FROM carts')
        erb :'buys/show'
    end

    get '/buy' do
        session[:cart] = []
        erb :'buys/copped'
    end 

end

