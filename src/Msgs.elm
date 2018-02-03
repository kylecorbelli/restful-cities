module Msgs exposing (..)

import Http
import Models exposing (..)


type Msg
    = FetchCitiesRequestComplete (Result Http.Error (List City))
    | FetchStatesRequestComplete (Result Http.Error (List State))
