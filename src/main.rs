#[macro_use]
extern crate diesel;
extern crate dotenv;

use dotenv::dotenv;
use std::env;
use diesel::prelude::*;

mod schema;
mod models;

fn main() {
    dotenv().ok();

    let db_url = env::var("DATABASE_URL").expect("Please set DATABASE_URL");
    let con = MysqlConnection::establish(&db_url).unwrap();

    let book = models::NewBook {
        title: String::from("Gravity's Rainbow"),
        author: String::from("Thomas Pynchon"),
        published: true,
    };

    if models::Book::insert(book, &con) {
        println!("Success!");
    } else {
        println!("Failed :(");
    }
}
