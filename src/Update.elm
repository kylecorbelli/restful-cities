module Update exposing (..)

import Commands exposing (..)
import Dict exposing (Dict, fromList)
import Models exposing (..)
import Msgs exposing (..)
import Navigation exposing (newUrl)
import Result
import Routing exposing (..)


isCityValid : List String -> Bool
isCityValid fieldValues =
    not (List.any String.isEmpty fieldValues)


updateCityFormField : CityId -> (EditCityFormFields -> EditCityFormFields) -> Model -> ( Model, Cmd Msg )
updateCityFormField cityId callback model =
    let
        existingEditEntities =
            model.editEntities

        existingCitiesById =
            model.editEntities.citiesById

        updatedCitiesById =
            Dict.update cityId (Maybe.map callback) existingCitiesById

        updatedEditEntities =
            { existingEditEntities | citiesById = updatedCitiesById }
    in
        ( { model | editEntities = updatedEditEntities }, Cmd.none )


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
                        ( { model | entities = updatedEntities }, Cmd.none )

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

                        cityToEditCityFormFields city =
                            { name = city.name
                            , population = city.population |> toString
                            , stateId = city.stateId
                            }

                        citiesEditFields =
                            cities
                                |> List.map (\city -> ( city.id, city |> cityToEditCityFormFields ))
                                |> Dict.fromList

                        originalEntities =
                            model.entities

                        updatedEntities =
                            { originalEntities | citiesById = citiesById }

                        existingEditEntities =
                            model.editEntities

                        updatedEditEntities =
                            { existingEditEntities | citiesById = citiesEditFields }
                    in
                        ( { model | entities = updatedEntities, editEntities = updatedEditEntities }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        OnLocationChange location ->
            let
                route =
                    parseLocation location

                newModel =
                    case model.route of
                        EditCityRoute cityId ->
                            case Dict.get cityId model.entities.citiesById of
                                Just city ->
                                    let
                                        existingEditEntities =
                                            model.editEntities

                                        existingEditEntitiesCitiesById =
                                            model.editEntities.citiesById

                                        newEditEntitiesCitiesById =
                                            Dict.update
                                                cityId
                                                (Maybe.map (\cityEditFields -> { name = city.name, population = city.population |> toString, stateId = city.stateId }))
                                                existingEditEntitiesCitiesById

                                        updatedEditEntities =
                                            { existingEditEntities | citiesById = newEditEntitiesCitiesById }
                                    in
                                        { model | route = route, editEntities = updatedEditEntities }

                                Nothing ->
                                    { model | route = route }

                        _ ->
                            { model | route = route }
            in
                ( newModel, Cmd.none )

        UpdateEditCityName cityId name ->
            updateCityFormField
                cityId
                (\cityFormField -> { cityFormField | name = name })
                model

        UpdateEditCityPopulation cityId population ->
            updateCityFormField
                cityId
                (\cityFormField -> { cityFormField | population = population })
                model

        UpdateEditCityState cityId stateId ->
            updateCityFormField
                cityId
                (\cityFormField -> { cityFormField | stateId = stateId })
                model

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

        EditCityRequestSent cityId ->
            case Dict.get cityId model.editEntities.citiesById of
                Just editCityFields ->
                    case ( editCityFields.population |> String.toInt, isCityValid [ editCityFields.name, editCityFields.population, editCityFields.stateId ] ) of
                        ( Ok population, True ) ->
                            let
                                city =
                                    City
                                        cityId
                                        editCityFields.name
                                        population
                                        editCityFields.stateId
                            in
                                ( model, updateCity city )

                        ( _, _ ) ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        EditCityRequestComplete result ->
            case result of
                Ok city ->
                    let
                        existingCitiesById =
                            model.entities.citiesById

                        updatedCitiesById =
                            Dict.update city.id (\targetCity -> (Result.toMaybe result)) existingCitiesById

                        existingEntities =
                            model.entities

                        updatedEntities =
                            { existingEntities | citiesById = updatedCitiesById }
                    in
                        ( { model | entities = updatedEntities, route = CitiesRoute }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

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

        DeleteCityRequestSent cityId ->
            ( model, deleteCity cityId )

        DeleteCityRequestComplete cityId result ->
            case result of
                Ok city ->
                    let
                        existingEntities =
                            model.entities

                        updatedCitiesById =
                            model.entities.citiesById
                                |> Dict.remove cityId

                        updatedEntities =
                            { existingEntities | citiesById = updatedCitiesById }
                    in
                        ( { model | entities = updatedEntities }, newUrl "#/cities" )

                Err error ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
