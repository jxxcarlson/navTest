module Main exposing (main)

{- This app retrieves and displays weather data from openweathermap.org. -}

import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Url
import Url.Parser as Parser exposing (Parser, (</>), custom, fragment, map, oneOf, s, top)

import Html
import Html.Attributes

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Element.Keyed as Keyed
import Element.Border as Border
import Element.Lazy



main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions 
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


-- TYPES


type alias Flags = { }


type alias Model =
    {   message  : String 
      , key : Nav.Key
    }

-- MSG

type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    



-- INIT

stepUrl : Url.Url -> Model -> (Model, Cmd Msg)
stepUrl url model =
  (model, Cmd.none)

init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg ) -- Flags -> ( Model, Cmd Msg )
init flags url key =
   ( {   message = "App started" 
            , key = Debug.log "key" key
        }
        , Cmd.none
    )



subscriptions model =
    Sub.none


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
       
        LinkClicked urlRequest ->
            case urlRequest of
              Browser.Internal url ->
                ( {model | message = "Internal url = " ++ (Url.toString url) }
                , Cmd.none -- Nav.pushUrl model.key (Url.toString url)
                )

              Browser.External url ->
                ( {model | message = "External url = " ++ url }
                , Cmd.none -- Nav.load url
                )

        UrlChanged url ->
          ( {model | message = "Internal url = " ++ (Url.toString url) }
                , Cmd.none 
                )
           -- stepUrl url model

-- VIEW

view : Model -> Browser.Document Msg
view model =
  {   title = "XKNODE"
    , body = [view_ model]
  }

view_ : Model -> Html.Html Msg
view_ model =
   Element.layout [Font.size 14, width fill, height fill, clipY] <|
        Element.column [ width fill, height fill, padding 30 ] 
        [
          Element.el [] (text model.message)
        ]
    
    

