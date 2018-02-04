module Views.City exposing (..)

import Debug exposing (log)
import Dict exposing (Dict)
import Html exposing (a, button, div, form, h1, h3, Html, input, li, option, p, select, text, ul)
import Html.Attributes exposing (disabled, href, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput, onWithOptions)
import Json.Decode as Decode
import Models exposing (City, CityId, Model, State, StateId)
import Msgs exposing (Msg(CreateCityRequestSent, DeleteCityRequestSent, UpdateNewCityName, UpdateNewCityPopulation, UpdateNewCityState))
import Selector


stateGivenCity : City -> Model -> Maybe State
stateGivenCity city model =
    Dict.get city.stateId model.entities.statesById


renderCityPreview : City -> Html Msg
renderCityPreview city =
    li []
        [ a [ href <| "#/cities/" ++ city.id ] [ text city.name ]
        ]


cityView : CityId -> Model -> Html Msg
cityView cityId model =
    case Dict.get cityId model.entities.citiesById of
        Just city ->
            let
                state =
                    stateGivenCity city model

                renderState =
                    case state of
                        Just { name } ->
                            h3 [] [ text name ]

                        Nothing ->
                            text ""
            in
                div []
                    [ h1 [] [ text city.name ]
                    , renderState
                    , p [] [ text <| toString city.population ]
                    , a [ href <| "#/cities/" ++ city.id ++ "/confirm-delete" ] [ text <| "Delete " ++ city.name ]

                    -- , button [ onClick (DeleteCityRequestSent cityId) ] [ text "Delete this city" ]
                    ]

        Nothing ->
            text "No City Found"


deleteCityConfirmation : CityId -> Model -> Html Msg
deleteCityConfirmation cityId model =
    case Dict.get cityId model.entities.citiesById of
        Just city ->
            div []
                [ h3 [] [ text <| "Permanently delete " ++ city.name ++ "?" ]
                , a [ href <| "#/cities/" ++ city.id ] [ text "Nevermind" ]
                , a [ onClick (DeleteCityRequestSent cityId) ] [ text "Confirm" ]
                ]

        Nothing ->
            h1 [] [ text "City not found" ]


citiesView : Model -> Html Msg
citiesView model =
    let
        cities =
            Selector.citiesList model
    in
        div []
            [ h1 [] [ text "Cities" ]
            , a [ href "#/cities/new" ] [ text "Add new city" ]
            , ul [] (List.map renderCityPreview cities)
            ]


renderStateOption : State -> Html Msg
renderStateOption { id, name } =
    option [ value id ]
        [ text name ]


newCityView : Model -> Html Msg
newCityView model =
    let
        states =
            Selector.statesList model
    in
        div []
            [ h1 [] [ text "Add New City" ]
            , form [ onWithOptions "submit" { stopPropagation = True, preventDefault = True } (Decode.succeed CreateCityRequestSent) ]
                [ input [ type_ "text", placeholder "city name", onInput UpdateNewCityName, value model.newCityFormFields.nameField ] []
                , input [ type_ "number", placeholder "city population", onInput UpdateNewCityPopulation, value model.newCityFormFields.populationField ] []
                , select [ onInput UpdateNewCityState ]
                    ([ option [ value "", disabled True, selected True ] [ text "Select a State" ] ]
                        ++ (List.map renderStateOption states)
                    )
                , button [ type_ "submit" ] [ text "Add City" ]
                ]
            ]
