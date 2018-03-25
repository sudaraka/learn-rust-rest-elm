use db::Con;
use rocket_contrib::Json;
use serde_json::Value;
use models::{Book, NewBook};

#[get("/")]
fn get(con: Con) -> Json<Value> {
    let books = Book::all(&con);

    Json(json!({
        "status": 200,
        "result": books,
    }))
}

#[get("/<id>")]
fn get_one(con: Con, id: i32) -> Json<Value> {
    let books = Book::show(id, &con);
    let status = if books.is_empty() { 404 } else { 200 };

    Json(json!({
        "status": status,
        "result": books.get(0),
    }))
}

#[post("/", format = "application/json", data = "<new_book>")]
fn create(con: Con, new_book: Json<NewBook>) -> Json<Value> {
    Json(json!({
        "status": Book::insert(new_book.into_inner(), &con),
        "result": Book::all(&con).first(),
    }))
}

#[put("/<id>", format = "application/json", data = "<book>")]
fn update(con: Con, id: i32, book: Json<NewBook>) -> Json<Value> {
    let status = if Book::update_by_id(id, &con, book.into_inner()) {
        200
    } else {
        404
    };

    Json(json!({
        "status": status,
        "result": null,
    }))
}

#[delete("/<id>")]
fn delete(con: Con, id: i32) -> Json<Value> {
    let status = if Book::delete_by_id(id, &con) {
        200
    } else {
        404
    };

    Json(json!({
        "status": status,
        "result": null,
    }))
}

#[get("/authors/<author>")]
fn get_by_author(author: String, con: Con) -> Json<Value> {
    Json(json!({
        "status": 200,
        "result": Book::all_by_author(author, &con),
    }))
}

#[error(404)]
fn not_found() -> Json<Value> {
    Json(json!({
        "status": "error",
        "reason": "Resource was not found",
    }))
}
