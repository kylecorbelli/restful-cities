module Main exposing (..)

import Commands exposing (..)
import Dict exposing (Dict)
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import Models exposing (..)
import Msgs exposing (..)
import Update exposing (update)


---- MODEL ----


initialModel : Model
initialModel =
    Model
        (Entities
            Dict.empty
            Dict.empty
        )


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchStates )



---- UPDATE ----
---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
