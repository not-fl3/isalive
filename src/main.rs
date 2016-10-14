extern crate iron;
extern crate router;
extern crate staticfile;
extern crate mount;
extern crate rustc_serialize;
extern crate toml;
extern crate bincode;
extern crate urlencoded;
extern crate queryst;

use iron::prelude::*;
use iron::status;
use router::Router;
use rustc_serialize::json;
use std::sync::{Arc, Mutex};
use staticfile::Static;
use mount::Mount;

mod history;
mod config;

use history::*;
use config::*;

fn get_services_history(req: &mut Request,
                   config : ServerConfig,
                   sdb: Arc<Mutex<ServicesHandler>>) -> IronResult<Response> {
    #[derive(RustcEncodable, RustcDecodable, Debug, Clone)]
    struct RequestHistory {
        id    : String,
        count : i32
    }

    let json_str = parse_request_to_json(req);
    let result_quary: RequestHistory = match json::decode(&json_str) {
        Ok(x) => x,
        Err(_) => {
            println!("services history request incorrect");
            return Ok(Response::with((status::BadRequest, "")));
        }
    };
    let mut sdb = sdb.lock().unwrap();
    let id = result_quary.id.parse::<i32>().unwrap();

    match config.services.iter().find(|x| x.id == id) {
        None => Ok(Response::with((status::Ok, ""))),
        Some(response) => {
            let result = (*sdb).get_last_history(&response.secret, result_quary.count);
            Ok(Response::with((status::Ok, result)))
        }
    }
}

fn get_server_info(_: &mut Request, config : ServerConfig) -> IronResult<Response> {
    #[derive(RustcEncodable, RustcDecodable, Debug)]
    struct InfoResponse{name:String, description:String, footer:String}

    let info_request = InfoResponse {
        name        : config.name,
        description : config.description,
        footer      : config.footer
    };
    let info = json::encode(&info_request).unwrap();

    Ok(Response::with((status::Ok, info)))
}

fn get_services_info(_        : &mut Request,
                     config   : ServerConfig) -> IronResult<Response> {
    let info = json::encode(&config.services).unwrap();

    Ok(Response::with((status::Ok, info)))
}

fn post_services_status(req      : &mut Request,
                        sdb      : Arc<Mutex<ServicesHandler>>) -> IronResult<Response> {
    #[derive(RustcEncodable, RustcDecodable, Debug, Clone)]
    struct RequestStateService {
        secret : String,
        status : String
    }

    let json_str = parse_request_to_json(req);
    let result_query: RequestStateService = match json::decode(&json_str) {
        Ok(x) => x,
        Err(_) => { println!("services request incorrect");
                    return Ok(Response::with((status::BadRequest, "")));}
    };
    let mut sdb = sdb.lock().unwrap();
    sdb.add_history(&result_query.secret, &result_query.status);
    &(*sdb).save();

    Ok(Response::with((status::Ok, "")))
}


fn parse_request_to_json(req: &mut Request) -> String {
    use queryst::parse;

    let url = req.url.clone().into_generic_url();
    parse(url.query().unwrap()).unwrap().to_string()
}


fn main() {
    let server_config = load_config();
    let services_handler = Arc::new(Mutex::new(ServicesHandler::load_from_file()));

    let mut router = Router::new();

    router.get("/project/info",
               {
                   let config = server_config.clone();

                   move |req : &mut Request| {
                       get_server_info(req, config.clone())
                   }
               },
               "serverInfo");

    router.get("/project/services/info",
               {
                   let config = server_config.clone();

                   move |req : &mut Request| {
                       get_services_info(req, config.clone())
                   }
               },
               "servicesInfo");

    router.post("/services/status",
                {
                    let sdb = services_handler.clone();

                    move |req : &mut Request| {
                        post_services_status(req, sdb.clone())
                    }
                },
                "servicesStatus");

    router.get("/project/services/history",
               {
                   let sdb = services_handler.clone();
                   let config = server_config.clone();

                   move |req : &mut Request| {
                       get_services_history(req, config.clone(), sdb.clone())
                   }
               },
               "services/history");

    let mut mount = Mount::new();

    mount.mount("/api", router)
        .mount("/", Static::new(::std::path::Path::new("static/")));

    Iron::new(mount).http("0.0.0.0:4000").unwrap();
}
