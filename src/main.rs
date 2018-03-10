#![feature(plugin)]
#![plugin(rocket_codegen)]

#[macro_use]
extern crate diesel;
extern crate dotenv;
extern crate r2d2;
extern crate r2d2_diesel;
extern crate rocket;
extern crate rocket_contrib;
#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate serde_json;

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
        .mount(
            "/books",
            routes![
                routes::books::get,
                routes::books::get_one,
                routes::books::get_by_author,
                routes::books::create,
                routes::books::update,
                routes::books::delete
            ],
        )
        .catch(errors![routes::books::not_found])
}

fn main() {
    rocket().launch();
}
