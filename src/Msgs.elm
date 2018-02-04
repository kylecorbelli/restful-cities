module Msgs exposing (..)

import Dict exposing (Dict)
import Http
import Models exposing (..)
import Navigation exposing (Location)


type Msg
    = FetchCitiesRequestComplete (Result Http.Error (List City))
    | FetchStatesRequestComplete (Result Http.Error (List State))
    | OnLocationChange Location
    | UpdateNewCityState StateId
    | UpdateNewCityName String
    | UpdateNewCityPopulation String
    | CreateCityRequestSent
    | CreateCityRequestComplete (Result Http.Error City)
    | DeleteCityRequestSent CityId
    | DeleteCityRequestComplete CityId (Result Http.Error (Dict String String))
    | NoOp
