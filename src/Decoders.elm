module Decoders exposing (..)

import Json.Decode as Decode exposing (..)
import Models exposing (..)


cityDecoder : Decoder City
cityDecoder =
    map4 City
        (field "id" string)
        (field "name" string)
        (field "population" int)
        (field "stateId" string)


citiesDecoder : Decoder (List City)
citiesDecoder =
    list cityDecoder


stateDecoder : Decoder State
stateDecoder =
    map3 State
        (field "abbreviation" string)
        (field "id" string)
        (field "name" string)


statesDecoder : Decoder (List State)
statesDecoder =
    list stateDecoder
