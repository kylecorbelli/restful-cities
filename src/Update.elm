module Update exposing (..)

import Commands exposing (..)
import Debug exposing (log)
import Dict exposing (Dict, fromList)
import Models exposing (..)
import Msgs exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchStatesRequestComplete statesResult ->
            case statesResult of
                Ok states ->
                    let
                        statesById =
                            states
                                |> List.map (\state -> ( state.id, state ))
                                |> Dict.fromList

                        originalEntities =
                            model.entities

                        updatedEntities =
                            { originalEntities | statesById = statesById }
                    in
                        ( { model | entities = updatedEntities }, fetchCities )

                Err _ ->
                    ( model, Cmd.none )

        FetchCitiesRequestComplete citiesResult ->
            case citiesResult of
                Ok cities ->
                    let
                        citiesById =
                            cities
                                |> List.map (\city -> ( city.id, city ))
                                |> Dict.fromList

                        originalEntities =
                            model.entities

                        updatedEntities =
                            { originalEntities | citiesById = citiesById }
                    in
                        ( { model | entities = updatedEntities }, Cmd.none )

                Err error ->
                    let
                        _ =
                            log "error" error
                    in
                        ( model, Cmd.none )
