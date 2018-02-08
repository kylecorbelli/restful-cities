module Views.City exposing (..)

import Dict exposing (Dict)
import Html exposing (a, button, div, form, h1, h3, Html, input, li, option, p, select, text, ul)
import Html.Attributes exposing (class, disabled, href, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput, onWithOptions)
import Json.Decode as Decode
import Models exposing (City, CityId, Model, State, StateId)
import Msgs exposing (Msg(..))
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
                    , p [] [ text <| "population: " ++ toString city.population ]
                    , a [ class "btn mr--1", href <| "#/cities/" ++ city.id ++ "/edit" ] [ text <| "Edit " ++ city.name ]
                    , a [ class "btn ml--1", href <| "#/cities/" ++ city.id ++ "/confirm-delete" ] [ text <| "Delete " ++ city.name ]
                    ]

        Nothing ->
            text "No City Found"


deleteCityConfirmation : CityId -> Model -> Html Msg
deleteCityConfirmation cityId model =
    case Dict.get cityId model.entities.citiesById of
        Just city ->
            div []
                [ h3 [] [ text <| "Permanently delete " ++ city.name ++ "?" ]
                , a [ class "btn mr--1", href <| "#/cities/" ++ city.id ] [ text "Nevermind" ]
                , a [ class "btn ml--1", onClick (DeleteCityRequestSent cityId) ] [ text "Confirm" ]
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
            , a [ class "btn", href "#/cities/new" ] [ text "Add new city" ]
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


renderEditStateOption : StateId -> State -> Html Msg
renderEditStateOption stateId state =
    option [ selected (stateId == state.id), value state.id ]
        [ text state.name ]


editCityView : CityId -> Model -> Html Msg
editCityView cityId model =
    case ( Dict.get cityId model.entities.citiesById, Dict.get cityId model.editEntities.citiesById ) of
        ( Just city, Just cityFormFields ) ->
            let
                states =
                    Selector.statesList model
            in
                div []
                    [ h1 [] [ text <| "Edit " ++ city.name ]
                    , a [ class "btn mb--1", href <| "#/cities/" ++ city.id ] [ text "Cancel" ] -- might have to make this a message that clears the inputs then triggers a new route command
                    , form [ onWithOptions "submit" { stopPropagation = True, preventDefault = True } (Decode.succeed (EditCityRequestSent city.id)) ]
                        [ input [ type_ "text", placeholder "city name", onInput (UpdateEditCityName cityId), value cityFormFields.name ] []
                        , input [ type_ "number", placeholder "city population", onInput (UpdateEditCityPopulation cityId), value cityFormFields.population ] []
                        , select [ onInput (UpdateEditCityState cityId) ]
                            ([ option [ value "", disabled True, selected True ] [ text "Select a State" ] ]
                                ++ (List.map (renderEditStateOption city.stateId) states)
                            )
                        , button [ type_ "submit" ] [ text "Confirm Edit" ]
                        ]
                    ]

        ( _, _ ) ->
            h3 [] [ text "City Not Found" ]
