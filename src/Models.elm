module Models exposing (..)

import Dict exposing (Dict)


type alias StateId =
    String


type alias CityId =
    String


type alias State =
    { abbreviation : String
    , id : StateId
    , name : String
    }


type alias City =
    { id : CityId
    , name : String
    , population : Int
    , stateId : StateId
    }



-- How can we clean this up?


type alias CityPayload =
    { name : String
    , population : Int
    , stateId : StateId
    }


type alias Entities =
    { citiesById : Dict CityId City
    , statesById : Dict StateId State
    }


type alias EditEntities =
    { citiesById : Dict CityId EditCityFormFields
    }


type Route
    = StatesRoute
    | StateRoute StateId
    | CitiesRoute
    | CityRoute CityId
    | NewCityRoute
    | EditCityRoute CityId
    | DeleteCityConfirmationRoute CityId
    | NotFoundRoute


type alias NewCityFormFields =
    { nameField : String
    , populationField : String
    , stateId : StateId
    }


type alias EditCityFormFields =
    { name : String
    , population : String
    , stateId : StateId
    }


type alias Model =
    { entities : Entities
    , editEntities : EditEntities
    , route : Route
    , newCityFormFields : NewCityFormFields
    , editCityFormFields : EditCityFormFields
    }
