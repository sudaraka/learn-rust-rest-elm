use r2d2;
use r2d2_diesel::ConnectionManager;
use diesel::MysqlConnection;
use rocket::http::Status;
use rocket::request::{self, FromRequest};
use rocket::{Outcome, Request, State};
use std::ops::Deref;

pub type Pool = r2d2::Pool<ConnectionManager<MysqlConnection>>;

pub struct Con(pub r2d2::PooledConnection<ConnectionManager<MysqlConnection>>);

impl<'a, 'r> FromRequest<'a, 'r> for Con {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<Con, ()> {
        let pool = request.guard::<State<Pool>>()?;

        match pool.get() {
            Ok(con) => Outcome::Success(Con(con)),
            Err(_) => Outcome::Failure((Status::ServiceUnavailable, ())),
        }
    }
}

impl Deref for Con {
    type Target = MysqlConnection;

    #[inline(always)]
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

pub fn init_pool(db_url: String) -> Pool {
    let manager = ConnectionManager::<MysqlConnection>::new(db_url);

    r2d2::Pool::new(manager).expect("db pool failure")
}
