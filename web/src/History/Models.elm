module History.Models exposing (..)

import Time exposing (Time)

type ServiceStatus = Good | Bad | Unknown

type alias HistoryItem =
    { status : ServiceStatus
    , time   : Time
    }

type alias History =
    { id      : Int
    , history : List HistoryItem
    }
