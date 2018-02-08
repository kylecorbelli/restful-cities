module Commands exposing (..)

import Http exposing (emptyBody, expectJson, jsonBody)
import Decoders exposing (..)
import Models exposing (City, CityId, CityPayload)
import Msgs exposing (..)
import Json.Encode as Encode


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000"


citiesUrl : String
citiesUrl =
    baseApiUrl ++ "/cities"


cityUrl : CityId -> String
cityUrl cityId =
    citiesUrl ++ "/" ++ cityId


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


updateCityEncoder : City -> Encode.Value
updateCityEncoder city =
    let
        attributes =
            [ ( "id", Encode.string city.name )
            , ( "name", Encode.string city.name )
            , ( "population", Encode.int city.population )
            , ( "stateId", Encode.string city.stateId )
            ]
    in
        Encode.object attributes


createNewCity : CityPayload -> Cmd Msg
createNewCity cityPayload =
    Http.post citiesUrl (cityEncoder cityPayload |> jsonBody) cityDecoder
        |> Http.send CreateCityRequestComplete


deleteCity : CityId -> Cmd Msg
deleteCity cityId =
    let
        request =
            Http.request
                { method = "DELETE"
                , body = emptyBody
                , expect = expectJson emptyObjectDecoder
                , headers = []
                , timeout = Nothing
                , url = cityUrl cityId
                , withCredentials = False
                }
    in
        request
            |> Http.send (DeleteCityRequestComplete cityId)


updateCity : City -> Cmd Msg
updateCity city =
    let
        request =
            Http.request
                { body = city |> updateCityEncoder |> jsonBody
                , expect = expectJson cityDecoder
                , headers = []
                , method = "PATCH"
                , timeout = Nothing
                , url = cityUrl city.id
                , withCredentials = False
                }
    in
        request
            |> Http.send EditCityRequestComplete
