require_relative 'modules/users'
require_relative 'modules/products'
require_relative 'modules/carts'

require 'sinatra/flash'

class App < Sinatra::Base
    enable :sessions
    register Sinatra::Flash 
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
    
    end


    before do 
        if session[:user_id]
            @user = Users.select(session[:user_id])
            if Carts.select(session[:user_id]) != nil
                cart_items = Carts.select(session[:user_id])
                
                @cart = []
                
                cart_items.each do |item|
                    @cart << item["product_id"]
                end
            end
        end
    end

  

    get '/' do
        redirect '/products'
    end

    get '/products' do
        @products = Products.all
        erb :'products/index'
    end

    get '/products/add' do
        erb :'products/new'
    end

    post '/products/add' do
        if @user['access_level'] == 2
            if params[:file] != nil
                file = params[:file][:tempfile]
                image_url = params[:file][:filename]
                directory = File.join(settings.root, "public", "img")
                FileUtils.mkdir_p(directory) unless File.directory?(directory)
                File.open(File.join(directory, image_url), "wb") do |f|
                    f.write(file.read)
                end
                name = params['name']
                desc = params['desc']
                price = params['price']
                image_url = params[:file][:filename]
                Products.insert(h(name), h(desc), h(price), image_url)
            else
                "No image uploaded"
            end
        end

        redirect '/products'
    end


    get '/products/:id' do |id|
        @product = Products.select(id)
        @comments = Products.comments(id)
        @product_tags = Products.tags(id)
        erb :'products/show'
        
    end

    post '/products/:id' do |id|
        @id = id
        Products.createComment( h(params['comment']), @user['username'], id)
        redirect "/products/#{id}"
    end


    get '/login' do
        erb :'users/login'
    end

    post '/login' do
        user_data = Users.selectWithUsername(h(params['username']))
        
        if (user_data != nil)
            if Users.last_login_attempt(user_data['id'])
                latest_attempt = Users.last_login_attempt(user_data['id'])['date']
                if Time.now - Time.parse(latest_attempt) <= 3
                    puts "FART FARt FART"
                    flash[:tranquilo] = "SAKTA I BACKARNA BRUSH, vänta 3 sekunder innan du försöker igen"
                    redirect '/login'
                end
            end
 
            if BCrypt::Password.new(user_data['hashed_pass']) == (h(params['password'].chomp))
                puts "Password matches!"
                Users.attempted_login(user_data['id'], 1)
                session[:user_id] = user_data['id']
                redirect '/products'
            else
                Users.attempted_login(user_data['id'], 0)
                puts "Password does not match!"
                redirect '/login'
            end
        else

            flash[:user_no_exist] = "User not found!"
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
        user_check = Users.selectWithUsername(h(params['username']))
        if user_check == nil
            hashed_pass = BCrypt::Password.create(h("#{params['cleartext_password'].chomp}") )
            Users.create(h(params['username']), hashed_pass, 1)
            redirect '/login'
        else
            puts "användarnamnet är upptaget yäni"
            redirect '/register'
        end
    end
        
    post '/carts/copped' do
        if session[:user_id]
            if @user['access_level'] >= 1
                Carts.delete(session[:user_id])
                puts "deleted from carts"
            else
                puts "ej inloggad"
            end
        end
        redirect '/carts/copped'
    end
    
    post '/carts/:id' do |id_product|
        if @user['access_level'] >= 1
            Carts.create(session[:user_id], id_product)
            puts "added to carts"
        end
        redirect '/products'
        
    end

    get '/carts/show' do
        @products = Products.all
        erb :'carts/show'
    end

    get '/carts/copped' do
        erb :'carts/copped'
    end 

    
    post '/products/show/delete/:id' do |id|
        if @user['access_level'] == 2
            puts "DELETE FÖRSÖK AV PRODUCT"
            Products.delete(id)
        end
        redirect '/products'
    end

end

