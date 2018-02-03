module Commands exposing (..)

import Http exposing (jsonBody)
import Decoders exposing (..)
import Models exposing (City, CityPayload)
import Msgs exposing (..)
import Json.Encode as Encode


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


cityEncoder : CityPayload -> Encode.Value
cityEncoder cityPayload =
    let
        attributes =
            [ ( "name", Encode.string cityPayload.name )
            , ( "population", Encode.int cityPayload.population )
            , ( "stateId", Encode.string cityPayload.stateId )
            ]
    in
        Encode.object attributes


createNewCity : CityPayload -> Cmd Msg
createNewCity cityPayload =
    Http.post citiesUrl (cityEncoder cityPayload |> jsonBody) cityDecoder
        |> Http.send CreateCityRequestComplete
