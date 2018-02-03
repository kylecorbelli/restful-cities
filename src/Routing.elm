module Routing exposing (..)

import Html exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (Location)
import UrlParser exposing (..)
import Views.City exposing (citiesView, cityView, newCityView)
import Views.State exposing (stateView, statesView)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ UrlParser.map StatesRoute top
        , UrlParser.map NewCityRoute (UrlParser.s "cities" </> UrlParser.s "new")
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

        NotFoundRoute ->
            text "Page Not Found"
