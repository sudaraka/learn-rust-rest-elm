module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json


type Msg
    = GetBooks (Result Http.Error (List Book))
    | RequestBooks


type alias Book =
    { title : String
    , author : String
    , published : Bool
    }


type alias Model =
    { books : List Book }


init =
    ( Model [], Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetBooks (Ok json) ->
            ( { model | books = json }, Cmd.none )

        GetBooks (Err e) ->
            ( Debug.log (toString e) model, Cmd.none )

        RequestBooks ->
            ( model, getBooks )


getBooks : Cmd Msg
getBooks =
    let
        url =
            "http://127.0.0.1:5000/books"

        req =
            Http.get url decodeBooks
    in
        Http.send GetBooks req


decodeBooks : Json.Decoder (List Book)
decodeBooks =
    Json.at [ "result" ] (Json.list bookDeoder)


bookDeoder : Json.Decoder Book
bookDeoder =
    Json.map3
        Book
        (Json.at [ "title" ] Json.string)
        (Json.at [ "author" ] Json.string)
        (Json.at [ "published" ] Json.bool)


view : Model -> Html Msg
view model =
    div []
        [ div [] <| List.map bookView model.books
        , button [ onClick RequestBooks ] [ text "Get Books!" ]
        ]


bookView : Book -> Html Msg
bookView book =
    ul []
        [ li [] [ text book.title ]
        , li [] [ text book.author ]
        , li [] [ book.published |> toString |> text ]
        ]


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = (\_ -> Sub.none)
        }
