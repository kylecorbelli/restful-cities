module Update exposing (..)

import Commands exposing (..)
import Debug exposing (log)
import Dict exposing (Dict, fromList)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (newUrl)
import Routing exposing (..)


isCityValid : List String -> Bool
isCityValid fieldValues =
    not (List.any String.isEmpty fieldValues)


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

        OnLocationChange location ->
            let
                route =
                    parseLocation location
            in
                ( { model | route = route }, Cmd.none )

        UpdateNewCityName name ->
            let
                originalNewCityFormFields =
                    model.newCityFormFields

                updatedNewCityFormFields =
                    { originalNewCityFormFields | nameField = name }
            in
                ( { model | newCityFormFields = updatedNewCityFormFields }, Cmd.none )

        UpdateNewCityPopulation population ->
            let
                originalNewCityFormFields =
                    model.newCityFormFields

                updatedNewCityFormFields =
                    { originalNewCityFormFields | populationField = population }
            in
                ( { model | newCityFormFields = updatedNewCityFormFields }, Cmd.none )

        UpdateNewCityState stateId ->
            let
                originalNewCityFormFields =
                    model.newCityFormFields

                updatedNewCityFormFields =
                    { originalNewCityFormFields | stateId = stateId }
            in
                ( { model | newCityFormFields = updatedNewCityFormFields }, Cmd.none )

        CreateCityRequestSent ->
            case ( model.newCityFormFields.populationField |> String.toInt, isCityValid [ model.newCityFormFields.nameField, model.newCityFormFields.populationField, model.newCityFormFields.stateId ] ) of
                ( Ok population, True ) ->
                    let
                        cityPayload =
                            CityPayload
                                model.newCityFormFields.nameField
                                population
                                model.newCityFormFields.stateId

                        updatedNewCityFormFields =
                            { nameField = ""
                            , populationField = ""
                            , stateId = ""
                            }
                    in
                        ( { model | newCityFormFields = updatedNewCityFormFields }, createNewCity cityPayload )

                ( _, _ ) ->
                    ( model, Cmd.none )

        CreateCityRequestComplete result ->
            case result of
                Ok city ->
                    let
                        existingEntities =
                            model.entities

                        updatedCitiesById =
                            Dict.insert city.id city model.entities.citiesById

                        updatedEntities =
                            { existingEntities | citiesById = updatedCitiesById }
                    in
                        ( { model | entities = updatedEntities }, newUrl ("#/cities/" ++ city.id) )

                Err error ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
