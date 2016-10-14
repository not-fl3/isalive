module History.View exposing(..)

import Maybe

import Date

import Html exposing (..)
import Html.Attributes exposing (..)

import Services.Messages exposing (Msg(..))
import History.Models exposing (History, ServiceStatus(..))

tableStyle : List (String, String)
tableStyle =
    [ ("border", "1px solid #eee")
    , ("padding-left", "3px")
    , ("padding-right", "3px")
    , ("align", "middle")
    ]

viewHistory : Maybe History -> Int -> String -> List (Html Msg)
viewHistory history service_id description =
    let
        toImg status = case status of
                           Good -> "GOOD"
                           Bad -> "BAD"
                           Unknown -> "UNKNOWN"
        loading = [ div [] [text description]
                  , div [] [img [height 50, src "assets/loading.gif"] []]]
        dateToString date = toString (Date.month date)++
                            "/" ++ toString (Date.day date) ++
                            " - " ++ toString (Date.hour date) ++
                            ":" ++ toString (Date.minute date)
        dateText = .time >> Date.fromTime >> dateToString >> text
        dateStatus = .status >> toImg >> text
        rtd x = td [style tableStyle] [x]
        historyTable history = [ div [] <| [table [style tableStyle]
                                                [ tbody [] [ tr [] <| List.map (rtd << dateText) history
                                                           , tr [] <| List.map (rtd << dateStatus) history]]]]

    in
        case history of
            Maybe.Nothing -> loading
            Maybe.Just {id, history} ->if id == service_id then [text description] ++ historyTable history else loading
