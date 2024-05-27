module Users

    def self.db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    def self.all
        db.execute('SELECT * FROM users')
    end

    def self.create(username, hashed_pass, access_level)
        db.execute('INSERT INTO users (username, hashed_pass, access_level) VALUES (?,?,?)', username, hashed_pass, accesTis_level)
    end

    def self.select(userId)
        db.execute('SELECT * FROM users WHERE id = ?', userId).first
    end

    def self.selectWithUsername(username)
        db.execute('SELECT * FROM users WHERE username = ?', username).first
    end

    def self.last_login_attempt(user_id)
        db.execute('SELECT * FROM login_attempt WHERE user_id = ? AND successful = 0 ORDER BY id desc', user_id).first
    end

    def self.attempted_login(user_id, successful)
        db.execute('INSERT INTO login_attempt (user_id, successful, date) VALUES(?,?,?)', user_id, successful, Time.now.strftime("%Y-%m-%d %H:%M:%S.%L"))
    end

end