
require 'pry'
class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def self.create(hash)
        self.new(hash).save
    end

    def self.new_from_db(row)
        new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL 
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
        SQL

        db = DB[:conn].execute(sql, name, breed)[0]
        if db != nil
            Dog.new(id: db[0], name: db[1], breed: db[2])
        else 
            Dog.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def update 
        sql = <<-SQL
            UPDATE dogs 
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs(name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]    
        end
        self
    end

end


