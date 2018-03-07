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
