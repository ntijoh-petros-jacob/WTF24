require 'sqlite3'

def db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

def drop_tables
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS products')
    db.execute('DROP TABLE IF EXISTS product_tags')
    db.execute('DROP TABLE IF EXISTS tags')
    db.execute('DROP TABLE IF EXISTS comments')
end

def create_tables
    db.ececute('CREATE TABLE "users" (
        "id"	INTEGER UNIQUE,
        "username"	TEXT NOT NULL UNIQUE,
        "hashed_pass"	TEXT NOT NULL,
        "access_level"	INTEGER NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    
    db.ececute('CREATE TABLE "products" (
        "id"	INTEGER UNIQUE,
        "desc"	TEXT,
        "price"	INTEGER NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')

    db.ececute('CREATE TABLE "product_tags" (
        "id"	INTEGER NOT NULL,
        "product_id"	INTEGER NOT NULL UNIQUE,
        "tag_id"	INTEGER NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.ececute('CREATE TABLE "tags" (
        "id"	INTEGER NOT NULL,
        "tag"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.ececute('CREATE TABLE "comments" (
        "id"	INTEGER UNIQUE,
        "content"	TEXT NOT NULL,
        "commentor"	TEXT,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
  
end

def seed_tables

    users.each do |user|
        db.execute('INSERT INTO users (username, hashed_pass, access_level) VALUES (?,?,?)', users[:username], users[:hashed_pass],users[:access_level])
    end

    products.each do |product|
        db.execute('INSERT INTO products (desc, price) VALUES (?,?)', prodcuts[:desc], products[:price])
    end

    product_tags.each do |product_tag|
        db.execute('INSERT INTO product_tags (product_id, tag_id) VALUES (?,?)', product_tags[:product_id], product_tags[:tag_id])
    end

    tags.each do |tag|
        db.execute('INSERT INTO tags (tag) VALUES (?)', tags[:tag])
    end

    comments.each do |comments|
        db.execute('INSERT INTO comments (product_id, tag_id) VALUES (?,?)', product_tags[:product_id], product_tags[:tag_id])
    end



end

drop_tables
create_tables
seed_tables