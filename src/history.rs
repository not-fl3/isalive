use std::time::{SystemTime, UNIX_EPOCH};
use std::collections::VecDeque;
use rustc_serialize::*;

#[derive(Debug, Clone)]
pub enum BuildState {
    Good,
    Bad
}

#[derive(Debug, Clone)]
pub struct  ServiceStatus {
    time  : u64,
    status : BuildState
}

impl Encodable for ServiceStatus {
    fn encode<S: Encoder>(&self, s: &mut S) -> Result<(), S::Error> {
        s.emit_struct("ServiceStatus", 2, |s| {
            try!(s.emit_struct_field("time", 0, |s| {
                s.emit_u64(self.time)
            }));
            try!(s.emit_struct_field("status", 1, |s| {
                match self.status {
                    BuildState::Good => s.emit_str("GOOD"),
                    BuildState::Bad => s.emit_str("BAD")
                }
            }));

            Ok(())
        })
    }
}

impl Decodable for ServiceStatus {
    fn decode<D: Decoder>(d: &mut D) -> Result<ServiceStatus, D::Error> {
        d.read_struct("ServiceStatus", 4, |d| {
            Ok(ServiceStatus {
                time  : try!(d.read_struct_field("time", 0, |d| { Decodable::decode(d) })),
                status : try!(d.read_struct_field("status", 1, |d| {
                    let status : Result<String, _> = Decodable::decode(d);
                    status.and_then(|status| match status.as_ref() {
                        "GOOD" => Ok(BuildState::Good),
                        "BAD" => Ok(BuildState::Bad),
                        _ => Err(d.error("invalid build state"))
                    })
                })),
            })
        })
    }
}

#[derive(RustcEncodable, RustcDecodable, Debug, Clone)]
pub struct ServiceHistory {
    pub secret  : String,
    history : VecDeque<ServiceStatus>
}

impl ServiceHistory {
    pub fn new(secret : String) -> ServiceHistory {
        ServiceHistory {
            secret  : secret,
            history : VecDeque::new()
        }
    }
    pub fn add(&mut self, state: BuildState) {
        let now = SystemTime::now();
        let seconds_since = now.duration_since(UNIX_EPOCH).unwrap().as_secs();
        self.history.push_front(ServiceStatus{time : seconds_since, status : state})
    }
    pub fn get_last_n_elements(&mut self, n: i32) -> Vec<&ServiceStatus> {
        self.history.iter().take(n as usize).collect()
    }
}

#[derive(RustcEncodable, RustcDecodable, Debug, Clone)]
pub struct ServicesHandler {
    services   : Vec<ServiceHistory>
}

impl ServicesHandler {
    pub fn new() -> ServicesHandler {
        ServicesHandler {
            services: Vec::new()
        }
    }

    pub fn load_from_file() -> ServicesHandler {
        let path = ::std::path::Path::new("db/history.toml");

        if path.exists() == false {
            println!("History not found, creating");
            return ServicesHandler::new();
        }

        ::config::load_toml(&path).unwrap()
    }

    pub fn save(&self) {
        use std::io::Write;

        let encoded = ::toml::encode_str(self);
        let mut f =  ::std::fs::File::create("db/history.toml").unwrap();

        f.write_all(encoded.as_bytes()).unwrap();
    }

    pub fn add_history(&mut self, secret : &str, status : &str) {
        let status = match status.as_ref() {
            "good" => BuildState::Good,
            "bad" => BuildState::Bad,
            _ => panic!("invalid request (not \"good\"/\"bad\")")
        };

        for service_history in self.services.iter_mut() {
            if service_history.secret == secret {
                service_history.add(status);
                println!("{:?}", "finded");
                return;
            }
        }

        println!("creating new");
        let mut history = ServiceHistory::new(secret.to_string());
        history.add(status);
        self.services.push(history);
    }

    pub fn get_last_history(&mut self, secret: &String, n: i32) -> String {
        for service_history in self.services.iter_mut() {
            if &service_history.secret == secret {
                return json::encode(&service_history.get_last_n_elements(n)).unwrap();
            }
        }
        return String::new();
    }
}

