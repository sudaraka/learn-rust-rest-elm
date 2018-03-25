module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Json
import Json.Encode as Encode
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN


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
    | NoOp


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

        NoOp ->
            ( model, Cmd.none )


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
    div [ class "jumbotron" ]
        [ CDN.stylesheet
        , cardView model
        ]


cardView : Model -> Html Msg
cardView model =
    Card.config []
        |> Card.header []
            [ h2 [] [ text "Elm Rust Book Database" ]
            ]
        |> Card.block []
            [ Block.custom <| bookForm model
            , Block.custom <| Button.button [ Button.success, Button.onClick RequestBooks ] [ text "Get Books!" ]
            , Block.custom <| br [] []
            , Block.custom <| div [] <| List.map bookView model.books
            ]
        |> Card.view


bookView : Book -> Html Msg
bookView book =
    ListGroup.ul
        [ ListGroup.li []
            [ span []
                [ b [] [ text "Title: " ]
                , p [] [ text book.title ]
                ]
            ]
        , ListGroup.li []
            [ span []
                [ b [] [ text "Author: " ]
                , p [] [ text book.author ]
                ]
            ]
        , ListGroup.li [ ListGroup.attrs [ class "justify-content-between" ] ]
            [ span []
                [ b [] [ text "Published: " ]
                , p [] [ book.published |> toString |> text ]
                ]
            , Button.button [ Button.danger, Button.onClick (RemoveBook book.id) ] [ text "X" ]
            ]
        ]


bookForm : Model -> Html Msg
bookForm model =
    Form.form []
        [ Form.group []
            [ Form.label [ for "title" ] [ text " Title " ]
            , Input.text [ Input.value model.title, Input.onInput GetTitle ]
            ]
        , Form.group []
            [ Form.label [ for "author" ] [ text " Author " ]
            , Input.text [ Input.value model.author, Input.onInput GetAuthor ]
            ]
        , Form.group []
            [ Form.label [ for "published" ] [ text " Author " ]
            , Checkbox.checkbox [ Checkbox.checked False, Checkbox.onCheck isChecked ] "Published ?"
            ]
        , Button.button [ Button.primary, Button.onClick PostBook ] [ text "Post Book!" ]
        ]


isChecked : Bool -> Msg
isChecked bool =
    if bool then
        GetPublished
    else
        NoOp


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = (\_ -> Sub.none)
        }
