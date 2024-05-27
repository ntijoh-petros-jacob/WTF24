module Carts
    def self.db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    def self.all
        db.execute('SELECT * FROM carts')
    end
    
    def self.select(id)
        db.execute('SELECT * FROM carts WHERE user_id = ?', id)
    end

    def self.delete(id)
        db.execute('DELETE FROM carts WHERE user_id = ?', id)
    end

    def self.create(user_id, id_product)
        db.execute('INSERT INTO carts (user_id, product_id) VALUES (?,?)', user_id, id_product)
    end



end

