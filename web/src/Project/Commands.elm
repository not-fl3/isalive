module Project.Commands exposing (..)

import Http
import Task
import Json.Decode exposing ((:=))

import Project.Messages exposing (Msg (..))
import Project.Models exposing (Project)

resourceUrl : String
resourceUrl =
    "/api/project/info"

projectDecoder : Json.Decode.Decoder Project
projectDecoder =
    Json.Decode.object3 Project
        ("name" := Json.Decode.string)
        ("description" := Json.Decode.string)
        ("footer" := Json.Decode.string)

fetchProject : Cmd Msg
fetchProject = Http.get projectDecoder resourceUrl
        |> Task.perform Fail FetchAllDone

