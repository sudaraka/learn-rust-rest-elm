#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate r2d2;
extern crate r2d2_diesel;

use dotenv::dotenv;
use std::env;

mod schema;
mod models;
mod db;

fn main() {
    dotenv().ok();

    let db_url = env::var("DATABASE_URL").expect("Please set DATABASE_URL");
    let pool = db::init_pool(db_url);
    let con = pool.get().unwrap();

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
