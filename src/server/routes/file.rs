use std::io;
use std::path::{Path, PathBuf};
use rocket::response::NamedFile;

#[get("/")]
fn index() -> io::Result<NamedFile> {
    NamedFile::open("public/index.html")
}

#[get("/<file..>", rank = 5)]
fn any(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("public/").join(file)).ok()
}
