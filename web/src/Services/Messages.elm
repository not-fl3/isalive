module Services.Messages exposing (..)

import Http

import Services.Models exposing (Service, ServiceStatus)

import History.Models exposing (History)

type Msg = NoOp
         | GetServiceHistory Int
         | Fail Http.Error
         | FailStatus Http.Error
         | FetchAllDone (List Service)
         | FetchStatusDone (Maybe (Int, ServiceStatus))
         | FetchHistoryDone History
