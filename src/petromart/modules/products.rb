module Products
    def self.db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    def self.all
        db.execute('SELECT * FROM products')
    end

    def self.insert(name, desc, price, image_url)
        db.execute("INSERT INTO products (name, desc, price, image_url) VALUES (?,?,?,?)", name, desc, price, image_url)
    end

    def self.select(id)
        db.execute("SELECT * FROM products WHERE id = ?", id).first
    end

    def self.comments(id)
        db.execute('SELECT * from products INNER JOIN comments ON products.id = comments.product_comment_id WHERE products.id = ?',id)  
    end

    def self.tags(id)
       db.execute('SELECT * FROM products JOIN product_tags ON products.id = product_tags.product_id JOIN tags ON product_tags.tag_id = tags.id WHERE products.id = ?',id)
    end

    def self.createComment(comment, username, id)
        db.execute("INSERT INTO comments (content, commentor, product_comment_id) VALUES (?,?,?)", comment, username, id)
    end

    def self.delete(id)
        db.execute('DELETE FROM products WHERE id = ?', id)
    end
end

