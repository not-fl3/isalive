use rustc_serialize::*;
use std::path::Path;
use std::fs::File;
use toml::{Value};
use std::io::{Read};

#[derive(Debug, Clone)]
pub struct ServiceConfig {
    pub name        : String,
    pub description : String,
    pub group       : String,
    pub secret      : String,
    pub id          : i32
}

impl Decodable for ServiceConfig {
    fn decode<D: Decoder>(d: &mut D) -> Result<ServiceConfig, D::Error> {
        d.read_struct("ServiceConfig", 4, |d| {
            Ok(ServiceConfig {
                name         : try!(d.read_struct_field("name", 0, |d| { Decodable::decode(d) })),
                description  : try!(d.read_struct_field("description", 0, |d| { Decodable::decode(d) })),
                group        : try!(d.read_struct_field("group", 0, |d| { Decodable::decode(d) })),
                secret       : try!(d.read_struct_field("secret", 0, |d| { Decodable::decode(d) })),
                id           : next_unique_id()
            })
        })
    }
}

impl Encodable for ServiceConfig {
    fn encode<S: Encoder>(&self, s: &mut S) -> Result<(), S::Error> {
        s.emit_struct("ServiceConfig", 4, |s| {
            try!(s.emit_struct_field("name", 0, |s| {
                s.emit_str(&self.name)
            }));
            try!(s.emit_struct_field("description", 1, |s| {
                s.emit_str(&self.description)
            }));
            try!(s.emit_struct_field("id", 2, |s| {
                s.emit_i32(self.id)
            }));

            Ok(())
        })
    }
}


fn next_unique_id() -> i32 {
    static mut ID : i32 = 0;
    unsafe { ID += 1; }
    unsafe { ID }
}
#[derive(RustcEncodable, RustcDecodable, Debug, Clone)]
pub struct ServerConfig {
    pub name        : String,
    pub description : String,
    pub footer      : String,
    pub services    : Vec<ServiceConfig>
}


pub fn load_toml<T : Decodable>(path : &Path) -> Result<T, String> {
    let mut s = String::new();
    let mut f = File::open(&path).unwrap();

    try!(f.read_to_string(&mut s).map_err(|_| "cant read file".to_string()));

    let mut parser = ::toml::Parser::new(&s);
    let toml = parser.parse().unwrap();
    let config = Value::Table(toml);
    let mut decoder = ::toml::Decoder::new(config);

    T::decode(&mut decoder).map_err(|_| "cant decode toml".to_string())
}

pub fn load_config() -> ServerConfig {
    let path = Path::new("config/config.toml");
    load_toml(path).unwrap()
}
