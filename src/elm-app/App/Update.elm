module App.Update exposing (..)

import App.Model exposing (..)


type Msg
    = Increment
    | Decrement
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 32, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
