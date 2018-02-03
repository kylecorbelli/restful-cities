module Views.State exposing (..)

import Dict exposing (Dict)
import Html exposing (a, div, h1, h3, Html, li, text, ul)
import Html.Attributes exposing (href)
import Models exposing (City, CityId, Model, State, StateId)
import Msgs exposing (Msg)


renderStatePreview : State -> Html Msg
renderStatePreview state =
    li []
        [ a [ href <| "#/states/" ++ state.id ] [ text state.name ]
        ]


renderCityPreview : City -> Html Msg
renderCityPreview city =
    li []
        [ a [ href <| "#/cities/" ++ city.id ] [ text city.name ]
        ]


citiesGivenState : StateId -> Dict CityId City -> List City
citiesGivenState stateId citiesById =
    citiesById
        |> Dict.toList
        |> List.map Tuple.second
        |> List.filter (\city -> city.stateId == stateId)


statesView : Model -> Html Msg
statesView model =
    let
        states =
            model.entities.statesById
                |> Dict.toList
                |> List.map Tuple.second
    in
        div []
            [ h1 [] [ text "States" ]
            , ul [] (List.map renderStatePreview states)
            ]


stateView : StateId -> Model -> Html Msg
stateView stateId model =
    case Dict.get stateId model.entities.statesById of
        Just state ->
            let
                cities =
                    citiesGivenState state.id model.entities.citiesById
            in
                div []
                    [ h1 [] [ text state.name ]
                    , h3 [] [ text "Cities" ]
                    , ul [] (List.map renderCityPreview cities)
                    ]

        Nothing ->
            text "No State found"
