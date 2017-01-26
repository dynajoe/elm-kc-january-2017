module App exposing (..)

import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2)
import Json.Decode as Decode
import Task
import RemoteData exposing (..)
import Http
import Date exposing (Date)
import Json.Decode.Extra as DecodeExtra exposing ((|:))
import Json.Encode as Encode


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL
-- The full application state of our todo app.


type alias Model =
    { entries : List Entry
    , field : String
    , uid : Int
    , visibility : String
    , todos : RemoteData.WebData (List Todo)
    }


type alias Entry =
    { todo : Todo
    , editing : Bool
    }


emptyModel : Model
emptyModel =
    { entries = []
    , visibility = "All"
    , field = ""
    , uid = 0
    , todos = RemoteData.NotAsked
    }


newEntry : Todo -> Entry
newEntry todo =
    { todo = todo
    , editing = False
    }


init : ( Model, Cmd Msg )
init =
    emptyModel ! [ getTodoList ]



-- UPDATE


{-| Users of our app can trigger messages by clicking and typing. These
messages are fed into the `update` function as they occur, letting us react
to them.
-}
type Msg
    = NoOp
    | UpdateField String
    | EditingEntry Todo Bool
    | UpdateEntry Todo String
    | Add
    | Delete Todo
    | DeleteComplete
    | Check Todo Bool
    | CheckAll Bool
    | TodosResponse (WebData (List Todo))
    | SaveTodoResponse (Result Http.Error Todo)
    | DeleteTodoResponse (Result Http.Error ())
    | ChangeVisibility String


type alias Todo =
    { todoId : Int
    , todoText : String
    , completed : Bool
    , createdOn : Date
    }


decodeTodo : Decode.Decoder Todo
decodeTodo =
    Decode.succeed
        Todo
        |: (Decode.field "todo_id" Decode.int)
        |: (Decode.field "text" Decode.string)
        |: (Decode.field "completed" Decode.bool)
        |: (Decode.field "created_on" DecodeExtra.date)


decodeTodos : Decode.Decoder (List Todo)
decodeTodos =
    Decode.list decodeTodo


getTodoList : Cmd Msg
getTodoList =
    Http.get "/todos" decodeTodos
        |> RemoteData.sendRequest
        |> Cmd.map TodosResponse


deleteTodo : Todo -> Cmd Msg
deleteTodo todo =
    Http.send DeleteTodoResponse <|
        Http.request
            { method = "DELETE"
            , headers = []
            , url = "/todos/" ++ (toString todo.todoId)
            , body = Http.emptyBody
            , expect = Http.expectJson <| Decode.succeed ()
            , timeout = Nothing
            , withCredentials = False
            }


updateTodo : Todo -> Cmd Msg
updateTodo todo =
    let
        body =
            Http.jsonBody <|
                Encode.object
                    [ ( "todo_id", Encode.int todo.todoId )
                    , ( "text", Encode.string todo.todoText )
                    , ( "completed", Encode.bool todo.completed )
                    ]
    in
        Http.send SaveTodoResponse <|
            Http.request
                { method = "PUT"
                , headers = []
                , url = "/todos"
                , body = body
                , expect = Http.expectJson decodeTodo
                , timeout = Nothing
                , withCredentials = False
                }


createTodo : String -> Cmd Msg
createTodo text =
    let
        body =
            Http.jsonBody <|
                Encode.object [ ( "text", Encode.string text ) ]
    in
        Http.send SaveTodoResponse <|
            Http.post "/todos" body decodeTodo



-- How we update our Model on a given Msg?


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TodosResponse response ->
            case response of
                RemoteData.Success todos ->
                    { model | entries = List.map newEntry todos } ! []

                RemoteData.Failure error ->
                    Debug.crash (toString error)

                _ ->
                    model ! []

        SaveTodoResponse response ->
            case response of
                Ok todo ->
                    let
                        updateEntry entry =
                            if todo.todoId == entry.todo.todoId then
                                { entry | todo = todo }
                            else
                                entry

                        updateExisting =
                            List.map updateEntry model.entries

                        maybeNewHead =
                            if not <| List.any ((==) todo.todoId << .todoId << .todo) model.entries then
                                [ newEntry todo ]
                            else
                                []
                    in
                        { model | entries = maybeNewHead ++ updateExisting } ! []

                Result.Err error ->
                    Debug.crash (toString error)

        DeleteTodoResponse response ->
            model ! []

        NoOp ->
            model ! []

        Add ->
            { model | field = "" } ! [ createTodo model.field ]

        UpdateField str ->
            { model | field = str } ! []

        EditingEntry todo isEditing ->
            let
                updateEntry entry =
                    if todo.todoId == entry.todo.todoId then
                        { entry | editing = isEditing }
                    else
                        entry

                focus =
                    Dom.focus ("todo-" ++ toString id)
            in
                { model | entries = List.map updateEntry model.entries }
                    ! [ Task.attempt (\_ -> NoOp) focus ]

        UpdateEntry todo newText ->
            model ! [ updateTodo { todo | todoText = newText } ]

        Delete todo ->
            { model | entries = List.filter (\t -> t.todo.todoId /= todo.todoId) model.entries } ! [ deleteTodo todo ]

        DeleteComplete ->
            { model | entries = List.filter (not << .completed << .todo) model.entries }
                ! []

        Check todo isCompleted ->
            model ! [ updateTodo { todo | completed = isCompleted } ]

        CheckAll isCompleted ->
            let
                updateEntry t =
                    updateTodo { t | completed = isCompleted }
            in
                model ! List.map (updateEntry << .todo) model.entries

        ChangeVisibility visibility ->
            { model | visibility = visibility }
                ! []



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "todomvc-wrapper"
        , style [ ( "visibility", "hidden" ) ]
        ]
        [ section
            [ class "todoapp" ]
            [ lazy viewInput model.field
            , lazy2 viewEntries model.visibility model.entries
            , lazy2 viewControls model.visibility model.entries
            ]
        , infoFooter
        ]


viewInput : String -> Html Msg
viewInput task =
    header
        [ class "header" ]
        [ h1 [] [ text "todos" ]
        , input
            [ class "new-todo"
            , placeholder "What needs to be done?"
            , autofocus True
            , value task
            , name "newTodo"
            , onInput UpdateField
            , onEnter Add
            ]
            []
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Decode.succeed msg
            else
                Decode.fail "not ENTER"
    in
        on "keydown" (Decode.andThen isEnter keyCode)



-- VIEW ALL ENTRIES


viewEntries : String -> List Entry -> Html Msg
viewEntries visibility entries =
    let
        isVisible entry =
            case visibility of
                "Completed" ->
                    entry.todo.completed

                "Active" ->
                    not entry.todo.completed

                _ ->
                    True

        allCompleted =
            List.all (.completed << .todo) entries

        cssVisibility =
            if List.isEmpty entries then
                "hidden"
            else
                "visible"
    in
        section
            [ class "main"
            , style [ ( "visibility", cssVisibility ) ]
            ]
            [ input
                [ class "toggle-all"
                , type_ "checkbox"
                , name "toggle"
                , checked allCompleted
                , onClick (CheckAll (not allCompleted))
                ]
                []
            , label
                [ for "toggle-all" ]
                [ text "Mark all as complete" ]
            , Keyed.ul [ class "todo-list" ] <|
                List.map viewKeyedEntry (List.filter isVisible entries)
            ]



-- VIEW INDIVIDUAL ENTRIES


viewKeyedEntry : Entry -> ( String, Html Msg )
viewKeyedEntry todo =
    ( toString todo.todo.todoId, lazy viewEntry todo )


viewEntry : Entry -> Html Msg
viewEntry entry =
    li
        [ classList [ ( "completed", entry.todo.completed ), ( "editing", entry.editing ) ] ]
        [ div
            [ class "view" ]
            [ input
                [ class "toggle"
                , type_ "checkbox"
                , checked entry.todo.completed
                , onClick (Check entry.todo (not entry.todo.completed))
                ]
                []
            , label
                [ onDoubleClick (EditingEntry entry.todo True) ]
                [ text entry.todo.todoText ]
            , button
                [ class "destroy"
                , onClick (Delete entry.todo)
                ]
                []
            ]
        , input
            [ class "edit"
            , value entry.todo.todoText
            , name "title"
            , id ("todo-" ++ toString entry.todo.todoId)
            , onInput (UpdateEntry entry.todo)
            , onBlur (EditingEntry entry.todo False)
            , onEnter (EditingEntry entry.todo False)
            ]
            []
        ]



-- VIEW CONTROLS AND FOOTER


viewControls : String -> List Entry -> Html Msg
viewControls visibility entries =
    let
        entriesCompleted =
            List.length (List.filter (.completed << .todo) entries)

        entriesLeft =
            List.length entries - entriesCompleted
    in
        footer
            [ class "footer"
            , hidden (List.isEmpty entries)
            ]
            [ lazy viewControlsCount entriesLeft
            , lazy viewControlsFilters visibility
            , lazy viewControlsClear entriesCompleted
            ]


viewControlsCount : Int -> Html Msg
viewControlsCount entriesLeft =
    let
        item_ =
            if entriesLeft == 1 then
                " item"
            else
                " items"
    in
        span
            [ class "todo-count" ]
            [ strong [] [ text (toString entriesLeft) ]
            , text (item_ ++ " left")
            ]


viewControlsFilters : String -> Html Msg
viewControlsFilters visibility =
    ul
        [ class "filters" ]
        [ visibilitySwap "#/" "All" visibility
        , text " "
        , visibilitySwap "#/active" "Active" visibility
        , text " "
        , visibilitySwap "#/completed" "Completed" visibility
        ]


visibilitySwap : String -> String -> String -> Html Msg
visibilitySwap uri visibility actualVisibility =
    li
        [ onClick (ChangeVisibility visibility) ]
        [ a [ href uri, classList [ ( "selected", visibility == actualVisibility ) ] ]
            [ text visibility ]
        ]


viewControlsClear : Int -> Html Msg
viewControlsClear entriesCompleted =
    button
        [ class "clear-completed"
        , hidden (entriesCompleted == 0)
        , onClick DeleteComplete
        ]
        [ text ("Clear completed (" ++ toString entriesCompleted ++ ")")
        ]


infoFooter : Html msg
infoFooter =
    footer [ class "info" ]
        [ p [] [ text "Double-click to edit a todo" ]
        , p []
            [ text "Written by "
            , a [ href "https://github.com/evancz" ] [ text "Evan Czaplicki" ]
            ]
        , p []
            [ text "Part of "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]
