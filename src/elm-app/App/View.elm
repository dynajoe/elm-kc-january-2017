module App.View exposing (..)

import App.Model exposing (..)
import App.Update exposing (..)
import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text <| "j" ++ (toString model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]
