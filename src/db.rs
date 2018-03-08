use r2d2;
use r2d2_diesel::ConnectionManager;
use diesel::MysqlConnection;
use std::ops::Deref;

pub type Pool = r2d2::Pool<ConnectionManager<MysqlConnection>>;

pub struct Con(pub r2d2::PooledConnection<ConnectionManager<MysqlConnection>>);

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
