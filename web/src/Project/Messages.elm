module Project.Messages exposing (..)

import Http

import Project.Models exposing (Project)

type Msg = NoOp
         | Fail Http.Error
         | FetchAllDone (Project)
