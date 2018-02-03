module Views.City exposing (..)

import Dict exposing (Dict)
import Html exposing (a, button, div, form, h1, h3, Html, input, li, option, select, text, ul)
import Html.Attributes exposing (disabled, href, placeholder, selected, type_, value)
import Html.Events exposing (onInput, onWithOptions)
import Json.Decode as Decode
import Models exposing (City, CityId, Model, State, StateId)
import Msgs exposing (Msg(CreateCityRequestSent, UpdateNewCityName, UpdateNewCityPopulation, UpdateNewCityState))
import Selector


renderCityPreview : City -> Html Msg
renderCityPreview city =
    li []
        [ a [ href <| "#/cities/" ++ city.id ] [ text city.name ]
        ]


cityView : CityId -> Model -> Html Msg
cityView cityId model =
    case Dict.get cityId model.entities.citiesById of
        Just city ->
            div []
                [ h1 [] [ text city.name ]
                ]

        Nothing ->
            text "No City Found"


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
