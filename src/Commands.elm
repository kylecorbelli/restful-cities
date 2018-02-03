module Commands exposing (..)

import Http
import Decoders exposing (..)
import Msgs exposing (..)


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000"


citiesUrl : String
citiesUrl =
    baseApiUrl ++ "/cities"


statesUrl : String
statesUrl =
    baseApiUrl ++ "/states"


fetchStates : Cmd Msg
fetchStates =
    Http.get statesUrl statesDecoder
        |> Http.send FetchStatesRequestComplete


fetchCities : Cmd Msg
fetchCities =
    Http.get citiesUrl citiesDecoder
        |> Http.send FetchCitiesRequestComplete
