module App.Main exposing (..)

import Html
import App.Model exposing (Model, initialModel)
import App.View exposing (view)
import App.Update as Update exposing (update)


main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
