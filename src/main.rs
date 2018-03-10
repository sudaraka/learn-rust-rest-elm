#![feature(plugin)]
#![plugin(rocket_codegen)]

#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate r2d2;
extern crate r2d2_diesel;
extern crate rocket;

use dotenv::dotenv;
use std::env;

mod schema;
mod models;
mod db;
mod routes;

fn rocket() -> rocket::Rocket {
    dotenv().ok();

    let db_url = env::var("DATABASE_URL").expect("Please set DATABASE_URL");
    let pool = db::init_pool(db_url);

    rocket::ignite()
        .manage(pool)
        .mount("/", routes![routes::file::any, routes::file::index])
}

fn main() {
    rocket().launch();
}
