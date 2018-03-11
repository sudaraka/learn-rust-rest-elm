use diesel;
use diesel::prelude::*;
use schema::book;
use schema::book::dsl::{self, book as all_books};

#[derive(Queryable, Serialize)]
pub struct Book {
    pub id: i32,
    pub title: String,
    pub author: String,
    pub published: bool,
}

#[derive(Insertable, Deserialize)]
#[table_name = "book"]
pub struct NewBook {
    pub title: String,
    pub author: String,
    pub published: bool,
}

impl Book {
    pub fn show(id: i32, con: &MysqlConnection) -> Vec<Book> {
        all_books
            .find(id)
            .load::<Book>(con)
            .expect("Error loading book")
    }

    pub fn all(con: &MysqlConnection) -> Vec<Book> {
        all_books
            .order(book::id.desc())
            .load::<Book>(con)
            .expect("Error loading book")
    }

    pub fn update_by_id(id: i32, con: &MysqlConnection, new_book: NewBook) -> bool {
        let NewBook {
            title,
            author,
            published,
        } = new_book;

        diesel::update(all_books.find(id))
            .set((
                dsl::author.eq(author),
                dsl::published.eq(published),
                dsl::title.eq(title),
            ))
            .execute(con)
            .is_ok()
    }

    pub fn insert(new_book: NewBook, con: &MysqlConnection) -> bool {
        diesel::insert_into(book::table)
            .values(&new_book)
            .execute(con)
            .is_ok()
    }

    pub fn delete_by_id(id: i32, con: &MysqlConnection) -> bool {
        if Book::show(id, con).is_empty() {
            return false;
        }

        diesel::delete(all_books.find(id)).execute(con).is_ok()
    }

    pub fn all_by_author(author: String, con: &MysqlConnection) -> Vec<Book> {
        all_books
            .filter(book::author.eq(author))
            .load::<Book>(con)
            .expect("Error loading books by author")
    }
}
