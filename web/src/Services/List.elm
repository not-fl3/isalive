module Services.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Services.Messages exposing (Msg(..))
import Services.Models exposing (Service, ServiceStatus(..))

-- just some common styles for table cells (th and td)
cellStyle : List (String, String)
cellStyle =
    [ ("textAlign", "left")
    , ("padding", "0px")
    ]

textCellStyle : List (String, String)
textCellStyle =
    [ ("textAlign", "left")
    , ("padding-left", "10px")
    , ("font-family", "molot")
    ]

tableStyle : List (String, String)
tableStyle =
    [ ("border", "0px solid #8e8")
    ]


view : (Int -> String -> List (Html Msg)) -> List Service -> Html Msg
view  history services =
    let
        tableRow s =
            div [style [("border-radius", "0px"), ("border", "0px")]
                , class "panel panel-default"]
                [ div []-- class "panel-heading"
                      [ serviceHeader s ]
                , div [id <| "collapse" ++ toString s.id,
                           class "panel-collapse collapse"]
                    [div [class "panel-body"] <| history s.id s.description]
                ]
    in
        div [class "panel-group", id "accordion"] <| List.map tableRow services


serviceHeader : Service -> Html Msg
serviceHeader t =
    let
        toImg status = case status of
                           Good -> "assets/good.jpg"
                           Bad -> "assets/bad.jpg"
                           Unknown -> "assets/unknown.jpg"
        row s = tr [ class "clickable-row"
                 , onClick <| GetServiceHistory t.id
                 , attribute "data-toggle" "collapse"
                 , attribute "data-parent" "#accordion"
                 , attribute "href" ("#collapse" ++ toString s.id)
                 , style tableStyle]
              [ td [ style <| textCellStyle ++ tableStyle ] [text s.name]
              , td [ style <| cellStyle ++ tableStyle ] [img [src <| toImg s.status] [] ]
              , td [ style <| cellStyle ++ tableStyle ] [
                     img [style [("padding-left", "10px")], height 10, src "assets/open.png"] [] ]
              ]
    in
        table [style tableStyle]
            [ tbody [] [row t]
            , col [width 220] []
            , col [width 100] []
            , col [width 50] []
            ]
