module Services.Models exposing (..)

type ServiceStatus = Good | Bad | Unknown

type alias Service =
    { id : Int
    , name : String
    , description : String
    , status : ServiceStatus
    }
