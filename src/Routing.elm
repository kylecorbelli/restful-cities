module Routing exposing (..)

import Html exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (Location)
import UrlParser exposing (..)
import Views.City exposing (citiesView, cityView, newCityView, deleteCityConfirmation, editCityView)
import Views.State exposing (stateView, statesView)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ UrlParser.map StatesRoute top
        , UrlParser.map NewCityRoute (UrlParser.s "cities" </> UrlParser.s "new")
        , UrlParser.map DeleteCityConfirmationRoute (UrlParser.s "cities" </> string </> UrlParser.s "confirm-delete")
        , UrlParser.map EditCityRoute (UrlParser.s "cities" </> string </> UrlParser.s "edit")
        , UrlParser.map StateRoute (UrlParser.s "states" </> string)
        , UrlParser.map StatesRoute (UrlParser.s "states")
        , UrlParser.map CityRoute (UrlParser.s "cities" </> string)
        , UrlParser.map CitiesRoute (UrlParser.s "cities")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


renderPage : Model -> Html Msg
renderPage model =
    case model.route of
        StatesRoute ->
            statesView model

        StateRoute stateId ->
            stateView stateId model

        CitiesRoute ->
            citiesView model

        CityRoute cityId ->
            cityView cityId model

        NewCityRoute ->
            newCityView model

        DeleteCityConfirmationRoute cityId ->
            deleteCityConfirmation cityId model

        EditCityRoute cityId ->
            editCityView cityId model

        NotFoundRoute ->
            text "Page Not Found"
