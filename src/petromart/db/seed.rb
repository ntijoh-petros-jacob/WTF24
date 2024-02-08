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
    db.execute('CREATE TABLE "users" (
        "id"	INTEGER UNIQUE,
        "username"	TEXT NOT NULL UNIQUE,
        "hashed_pass"	TEXT NOT NULL,
        "access_level"	INTEGER NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    
    db.execute('CREATE TABLE "products" (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "name" TEXT,
        "desc" TEXT,
        "price" INTEGER,
        "image_url" TEXT
    )')

    db.execute('CREATE TABLE "product_tags" (
        "id"	INTEGER NOT NULL,
        "product_id"	INTEGER NOT NULL UNIQUE,
        "tag_id"	INTEGER NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.execute('CREATE TABLE "tags" (
        "id"	INTEGER NOT NULL,
        "tag"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    db.execute('CREATE TABLE "comments" (
        "id"	INTEGER NOT NULL,
        "content"	TEXT NOT NULL,
        "commentor"	TEXT,
        "product_comment_id"  INTEGER,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
end

def seed_tables
    users = [
        {username: 'user1', hashed_pass: 'password1', access_level: 1},
        {username: 'user2', hashed_pass: 'password2', access_level: 2}
    ]

    products = [
        {name: 'Görgen CD', desc: 'Instrumental x ∈ inte primtal', price: 500, image_url: 'gorgencd.jpg'},
        {name: 'Goa Bananer!', desc: 'Långa gula frukter!', price: 15, image_url: 'gorgencd.jpg'},
        {name: 'Apple', desc: 'Fresh and juicy', price: 2, image_url: 'gorgencd.jpg'},
        {name: 'Orange', desc: 'Vitamin C-packed', price: 1, image_url: 'gorgencd.jpg'},
        {name: 'Milk', desc: 'Fresh milk', price: 3, image_url: 'gorgencd.jpg'},
        {name: 'Bread', desc: 'Whole grain bread', price: 2, image_url: 'gorgencd.jpg'},
        {name: 'Eggs', desc: 'Farm-fresh eggs', price: 4, image_url: 'gorgencd.jpg'}
    ]

    product_tags = [
        {product_id: 1, tag_id: 1},
        {product_id: 2, tag_id: 2}
    ]

    tags = [
        {tag: 'Tag1'},
        {tag: 'Tag2'}
    ]

    comments = [
        { content: "Great product!", commentor: "Joe", product_comment_id: "1" },
        { content: "Could be better.", commentor: "Peter Griffin", product_comment_id: "1" },
        { content: "Love it!", commentor: "Glenn", product_comment_id: "2" }
    ]

    # Inserting data into the tables
    users.each do |user|
        db.execute('INSERT INTO users (username, hashed_pass, access_level) VALUES (?,?,?)', user[:username], user[:hashed_pass], user[:access_level])
    end

    products.each do |product|
        db.execute('INSERT INTO products (name, desc, price, image_url) VALUES (?,?,?,?)', product[:name], product[:desc], product[:price], product[:image_url])
    end

    product_tags.each do |product_tag|
        db.execute('INSERT INTO product_tags (product_id, tag_id) VALUES (?,?)', product_tag[:product_id], product_tag[:tag_id])
    end

    tags.each do |tag|
        db.execute('INSERT INTO tags (tag) VALUES (?)', tag[:tag])
    end

    comments.each do |comment|
        db.execute('INSERT INTO comments (content, commentor, product_comment_id) VALUES (?,?,?)', comment[:content], comment[:commentor], comment[:product_comment_id])
    end
end


drop_tables
create_tables
seed_tables
