module Selector exposing (..)

import Dict
import Models exposing (Model, City, State)


entitiesList : { b | entities : a } -> (a -> Dict.Dict comparable a2) -> List a2
entitiesList model prop =
    model.entities
        |> prop
        |> Dict.toList
        |> List.map Tuple.second


citiesList : Model -> List City
citiesList model =
    entitiesList model .citiesById


statesList : Model -> List State
statesList model =
    entitiesList model .statesById
