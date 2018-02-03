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


type alias Entities =
    { citiesById : Dict CityId City
    , statesById : Dict StateId State
    }


type alias Model =
    { entities : Entities
    }
