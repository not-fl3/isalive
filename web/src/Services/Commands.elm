module Services.Commands exposing (..)

import Http
import Task
import Json.Decode exposing ((:=), succeed)

import Services.Messages exposing (Msg (..))
import Services.Models exposing (Service, ServiceStatus, ServiceStatus(..))

resourceUrl : String
resourceUrl = "/api/project/services/info"

historyUrl : Int -> Int -> String
historyUrl id n = "/api/project/services/history?id=" ++ toString id ++ "&count=" ++ toString n

serviceDecoder : Json.Decode.Decoder Service
serviceDecoder =
    Json.Decode.object4 Service
        ("id" := Json.Decode.int)
        ("name" := Json.Decode.string)
        ("description" := Json.Decode.string)
        (succeed Unknown)

servicesDecoder : Json.Decode.Decoder (List Service)
servicesDecoder = Json.Decode.list serviceDecoder

fetchServices : Cmd Msg
fetchServices = Http.get servicesDecoder resourceUrl |> Task.perform Fail FetchAllDone


statusDecoder : Json.Decode.Decoder ServiceStatus
statusDecoder = Json.Decode.object1 (\x -> x)
                (("status" := Json.Decode.string) `Json.Decode.andThen` decodeStatus)

decodeStatus : String -> Json.Decode.Decoder ServiceStatus
decodeStatus status = case status of
                          "GOOD" -> succeed Good
                          "BAD" -> succeed Bad
                          _ -> succeed Unknown

statusesDecoder : Json.Decode.Decoder (List ServiceStatus)
statusesDecoder = Json.Decode.list statusDecoder

fetchServicesStatus : List Int -> Cmd Msg
fetchServicesStatus ids =
    let
        get_status id = Http.get statusesDecoder (historyUrl id 1)
                      |> Task.map (Maybe.map ((,) id) << List.head)
                      |> Task.perform FailStatus FetchStatusDone
    in
        Cmd.batch <| List.map get_status ids

