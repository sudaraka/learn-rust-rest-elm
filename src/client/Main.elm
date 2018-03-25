module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Json
import Json.Encode as Encode


type Msg
    = GetBooks (Result Http.Error (List Book))
    | SetBook (Result Http.Error String)
    | DeleteBook (Result Http.Error String)
    | RequestBooks
    | PostBook
    | RemoveBook Int
    | GetTitle String
    | GetAuthor String
    | GetPublished


type alias Book =
    { title : String
    , author : String
    , published : Bool
    , id : Int
    }


type alias Model =
    { books : List Book
    , title : String
    , author : String
    , published : Bool
    , errorMsg : String
    }


init =
    ( Model [] "" "" False "", Cmd.none )


httpBookCompleted : Model -> Result Http.Error String -> ( Model, Cmd Msg )
httpBookCompleted model result =
    case result of
        Ok json ->
            ( { model | errorMsg = "" } |> Debug.log "Status Complete", Cmd.none )

        Err e ->
            ( { model | errorMsg = (toString e) }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetBooks (Ok json) ->
            ( { model | books = json }, Cmd.none )

        GetBooks (Err e) ->
            ( Debug.log (toString e) model, Cmd.none )

        RequestBooks ->
            ( model, getBooks )

        SetBook result ->
            httpBookCompleted model result

        DeleteBook result ->
            httpBookCompleted model result

        PostBook ->
            ( { model | title = "", author = "" }, bookPostCmd model )

        RemoveBook id ->
            ( { model | books = List.filter (\b -> b.id /= id) model.books }, delete id )

        GetTitle str ->
            ( { model | title = str }, Cmd.none )

        GetAuthor str ->
            ( { model | author = str }, Cmd.none )

        GetPublished ->
            ( { model | published = not model.published }, Cmd.none )


delete : Int -> Cmd Msg
delete id =
    let
        decoder =
            Json.succeed ""

        a =
            id |> toString

        request =
            Http.request
                { method = "DELETE"
                , headers = []
                , url = "http://127.0.0.1:5000/books/" ++ a
                , body = Http.emptyBody
                , expect = Http.expectJson decoder
                , timeout = Maybe.Nothing
                , withCredentials = False
                }
    in
        Http.send DeleteBook request


bookPostCmd : Model -> Cmd Msg
bookPostCmd model =
    Http.send SetBook (addBook model)


addBook : Model -> Http.Request String
addBook model =
    let
        url =
            "http://127.0.0.1:5000/books"

        body =
            model
                |> bookEncoder
                |> Http.jsonBody
    in
        Http.post url body statusDecoder


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
    Json.map4
        Book
        (Json.at [ "title" ] Json.string)
        (Json.at [ "author" ] Json.string)
        (Json.at [ "published" ] Json.bool)
        (Json.at [ "id" ] Json.int)


bookEncoder : Model -> Encode.Value
bookEncoder model =
    Encode.object
        [ ( "title", Encode.string model.title )
        , ( "author", Encode.string model.author )
        , ( "published", Encode.bool model.published )
        ]


statusDecoder : Json.Decoder String
statusDecoder =
    Json.field "status" Json.string


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick RequestBooks ] [ text "Get Books!" ]
        , bookForm model
        , div [] <| List.map bookView model.books
        ]


bookView : Book -> Html Msg
bookView book =
    ul []
        [ li [] [ text book.title ]
        , li [] [ text book.author ]
        , li [] [ book.published |> toString |> text ]
        , button [ onClick (RemoveBook book.id) ] [ text "X" ]
        ]


bookForm : Model -> Html Msg
bookForm model =
    div [ id "form" ]
        [ label [ for "title" ] [ text " Title " ]
        , input [ id "title", type_ "text", Html.Attributes.value model.title, onInput GetTitle ] []
        , label [ for "author" ] [ text " Author " ]
        , input [ id "author", type_ "text", Html.Attributes.value model.author, onInput GetAuthor ] []
        , label [ for "published" ] [ text " Author " ]
        , input [ id "published", type_ "checkbox", onClick GetPublished ] []
        , button [ onClick PostBook ] [ text "Post Book!" ]
        ]


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = (\_ -> Sub.none)
        }
