module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Html.App

import Time
import Debug

import Project.Models exposing (Project)
import Project.Commands
import Project.Messages as PM

import Services.Models exposing (Service, ServiceStatus)
import Services.Messages as SM
import Services.Commands
import Services.List

import History.View exposing (viewHistory)
import History.Models exposing (HistoryItem, History)
import History.Commands

import Style exposing (..)

-- MODEL

type alias Model =
    { project        : Maybe Project
    , services       : List Service
    , active_history : Maybe History
    }


-- INIT
init : (Model, Cmd Msg)
init = (Model Maybe.Nothing [] Maybe.Nothing, Cmd.batch [fetchSerives, fetchProject])

-- UPDATE

type Msg = Nothing
         | Tick Time.Time
         | ServicesMsg SM.Msg
         | ProjectMsg PM.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ServicesMsg(SM.Fail err) -> let _ = Debug.log "Services get fail" err in (model, fetchSerives)

        ProjectMsg(PM.Fail err) -> let _ = Debug.log "Project info fail" err in (model, fetchProject)

        ProjectMsg(PM.FetchAllDone proj) -> ({model | project = Maybe.Just(proj)}, Cmd.none)

        ServicesMsg(SM.FetchStatusDone Maybe.Nothing) -> let _ = Debug.log "History list was empty" "" in (model, fetchProject)

        ServicesMsg(SM.FetchStatusDone(Just (id, status))) -> ({model | services = setStatus model.services id status}, fetchProject)

        ServicesMsg(SM.FetchAllDone list) -> ({model | services = list}, fetchServicesStatus <| List.map .id list)

        ServicesMsg(SM.FetchHistoryDone history) -> ({model | active_history = Maybe.Just history}, Cmd.none)

        Tick(_) -> (model, fetchServicesStatus <| List.map .id model.services)

        ServicesMsg(SM.GetServiceHistory id) ->
            let
                cmd = Cmd.map ServicesMsg <| History.Commands.fetchServiceHistory id
            in
                (model, cmd)

        _ -> (model, Cmd.none)

setStatus : List Service -> Int -> ServiceStatus -> List Service
setStatus list id status =
    let
        --_ = Debug.log ("setStatus " ++ toString id) status
        update service = if service.id == id then { service | status = status } else service
    in
        List.map update list

fetchSerives : Cmd Msg
fetchSerives = Cmd.map ServicesMsg Services.Commands.fetchServices

fetchServicesStatus : List Int -> Cmd Msg
fetchServicesStatus ids = Cmd.map ServicesMsg <| Services.Commands.fetchServicesStatus ids

fetchProject : Cmd Msg
fetchProject = Cmd.map ProjectMsg Project.Commands.fetchProject

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = Time.every Time.minute Tick

-- VIEW

view : Model -> Html Msg
view {project, services, active_history} =
    case project of
        Maybe.Nothing -> img [src "assets/loading.gif", loadingImgStyle] []
        Maybe.Just(proj) -> site proj services active_history

site : Project -> List Service -> Maybe History -> Html Msg
site proj services history =
    body []
        [ div [ class "container", mainContainerStyle ]
              [ div [class "row"]
                    [ div [class "col-xs-7", contentColStyle]
                          [ div [] [span [projectNameFontStyle] [text proj.name]]
                          , div [projectDescriptionStyle] [text proj.description]
                          , div [tableDivStyle] [Html.App.map ServicesMsg <| Services.List.view (viewHistory history) services]
                          ]
                    , div [class "col-xs-5", imageColStyle]
                        [ div [] [img [backImgStyle, src "assets/back.png"] []] ]
                    ]
              , div [class "row"] [div [projectFooterStyle] [text proj.footer]]
              ]
        , footer [ class "footer", footerStyle]
            [ div [class "container"]
                  [ p [class "text-muted", style [("text-align", "center")]]
                      [a [href "https://twitter.com/BringerShar"] [text "about us"]]
                  ]
            ]
        ]

main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions }
