use diesel;
use diesel::prelude::*;
use schema::book;

#[derive(Queryable)]
pub struct Book {
    pub id: i32,
    pub title: String,
    pub author: String,
    pub published: bool,
}

#[derive(Insertable)]
#[table_name = "book"]
pub struct NewBook {
    pub title: String,
    pub author: String,
    pub published: bool,
}

impl Book {
    pub fn insert(new_book: NewBook, con: &MysqlConnection) -> bool {
        diesel::insert_into(book::table)
            .values(&new_book)
            .execute(con)
            .is_ok()
    }
}
