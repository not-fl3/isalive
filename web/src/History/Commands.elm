module History.Commands exposing (..)

import Http
import Task
import Json.Decode exposing ((:=), succeed)

import Services.Messages exposing (Msg (..))

import History.Models exposing (History, HistoryItem)
import History.Models as HM

historyUrl : Int -> Int -> String
historyUrl id n = "/api/project/services/history?id=" ++ toString id ++ "&count=" ++ toString n



decodeHistoryStatus : String -> Json.Decode.Decoder HM.ServiceStatus
decodeHistoryStatus status = case status of
                                 "GOOD" -> succeed HM.Good
                                 "BAD" -> succeed HM.Bad
                                 _ -> succeed HM.Unknown


historyItemDecoder : Json.Decode.Decoder HistoryItem
historyItemDecoder = Json.Decode.object2 HistoryItem
                (("status" := Json.Decode.string) `Json.Decode.andThen` decodeHistoryStatus)
                (("time" := Json.Decode.float))

historyDecoder : Json.Decode.Decoder (List HistoryItem)
historyDecoder = Json.Decode.list historyItemDecoder

fetchServiceHistory : Int -> Cmd Msg
fetchServiceHistory id =
    Http.get historyDecoder (historyUrl id 10)
        |> Task.perform FailStatus (\l -> FetchHistoryDone {history = l, id = id})
