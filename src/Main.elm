module Main exposing (..)

import Commands exposing (..)
import Dict exposing (Dict)
import Html exposing (a, Html, nav, text, div, h1, img)
import Html.Attributes exposing (class, href, src)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (Location)
import Routing exposing (..)
import Update exposing (update)


---- MODEL ----


initialModel : Route -> Model
initialModel route =
    { entities = (Entities Dict.empty Dict.empty)
    , editEntities = (EditEntities Dict.empty)
    , route = route
    , newCityFormFields =
        { nameField = ""
        , populationField = ""
        , stateId = ""
        }
    , editCityFormFields =
        { name = ""
        , population = ""
        , stateId = ""
        }
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            parseLocation location
    in
        ( initialModel route
        , Cmd.batch
            [ fetchStates
            , fetchCities
            ]
        )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ nav []
            [ a [ class "btn mr--1", href "#/states" ] [ text "States" ]
            , a [ class "btn ml--1", href "#/cities" ] [ text "Cities" ]
            ]
        , renderPage model
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
