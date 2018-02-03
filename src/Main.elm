module Main exposing (..)

import Commands exposing (..)
import Dict exposing (Dict)
import Html exposing (a, Html, nav, text, div, h1, img)
import Html.Attributes exposing (href, src)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (Location)
import Routing exposing (..)
import Update exposing (update)


---- MODEL ----


initialModel : Route -> Model
initialModel route =
    { entities = (Entities Dict.empty Dict.empty)
    , route = route
    , newCityFormFields =
        { nameField = ""
        , populationField = ""
        , stateId = ""
        }
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            parseLocation location
    in
        ( initialModel route, fetchStates )



---- UPDATE ----
---- VIEW ----
-- to : String -> Html.Attribute Msg


to turkey =
    onWithOptions
        "click"
        { preventDefault = True
        , stopPropagation = False
        }
        (Decode.succeed (OnLocationChange turkey))


view : Model -> Html Msg
view model =
    div []
        [ nav []
            [ a [ href "#/states" ] [ text "States" ]
            , a [ href "#/cities" ] [ text "Cities" ]
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
