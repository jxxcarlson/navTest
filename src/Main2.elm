module Main2 exposing(..)

import Browser.Navigation
import Browser
import Url
import Browser.Navigation as Nav
import Html exposing(Html)

import Element exposing (..)
import Element.Font as Font

import Parser exposing(..)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


type alias Model = {
        counter : Int
      , message : String
      , key : Browser.Navigation.Key
   }

init : flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( {  counter = 1
        , key = key
        , message = initialMessage url
      } 
      , Cmd.none 
    )


view : Model -> Browser.Document Msg
view model =
  {   title = "Nav Test"
    , body = [view_ model]
  }

view_ : Model -> Html Msg
view_ model =
   Element.layout [Font.size 14, width fill, height fill, clipY] <|
        Element.column [ width fill, height fill, padding 30, spacing 15 ] 
                [   Element.link  [Font.color (Element.rgb 0 0 1)]
                        { url = "/yo?yada=no"
                        , label = text "Internal link"
                        }

                   , Element.newTabLink  [Font.color (Element.rgb 0 0 1)]
                        { url = "http://elm-lang.org"
                        , label = text "elm-lang.org"
                        }
                   , Element.el [] (text model.message)
                ]
    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of 
    Zilch -> 
      ( {model | counter = model.counter + 1}, Cmd.none )
    HandleUrlRequest r -> 
       case r of 
         Browser.Internal url -> 
            ( {   model | message = internalUrlMessage url }
                , Nav.pushUrl model.key (Url.toString url)
            )
         Browser.External urlString -> ({model | message = externalUrlMessage urlString},  Nav.load urlString)
    UrlChange url ->
        ({model | message = changeUrlMessage url}, Nav.load (Url.toString url))
        

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest r =   
    HandleUrlRequest r


onUrlChange : Url.Url -> Msg
onUrlChange u =
   UrlChange u

type Msg = 
    Zilch 
    | HandleUrlRequest Browser.UrlRequest
    | UrlChange Url.Url

-- HELPERS 

initialMessage url = 
  case (Parser.run documentID url.path) of 
    Ok docID -> documentIDString docID 
    Err _ -> "Error parsing path (" ++ url.path ++ ")"

initialMessage1 url = 
  "Initial data: url, path = " ++ url.path ++ ", " ++ (url.query |> Maybe.withDefault "")

internalUrlMessage url = 
  "Internal url request: url, path = " ++ url.path ++ ", " ++ (url.query |> Maybe.withDefault "")

externalUrlMessage urlString = 
  "External: url = " ++ urlString

changeUrlMessage url = 
  "UrlChange: url, path = " ++ url.path ++ ", " ++ (url.query |> Maybe.withDefault "")

-- PARSER

type DocumentID = 
   DocumentID DocumentID_
   
type DocumentID_ = NumericalID Int | UUID String 

{-|  
    "Parser.run documentID /public/doc/123 => NumericalID 123
    "Parser.run documentID /public/doc/jxxcarslson.foo" => UUID "jxxcarlson.foo"
-}
documentID : Parser DocumentID 
documentID = 
  succeed DocumentID
    |. symbol "/public/doc/"
    |= oneOf [ numericalID, uuid ]


numericalID : Parser DocumentID_
numericalID = 
  Parser.map NumericalID int


uuid : Parser DocumentID_
uuid = 
  Parser.map UUID uuidString 

uuidString : Parser String
uuidString =
  getChompedString <|
    succeed ()
      |. chompIf isStartChar
      |. chompWhile isInnerChar

isStartChar : Char -> Bool
isStartChar char =
  Char.isAlpha char

isInnerChar : Char -> Bool
isInnerChar char =
  isStartChar char || Char.isDigit char ||  char == '_' ||  char == '.'

documentIDString : DocumentID -> String 
documentIDString (DocumentID documentID_)  = 
  case documentID_ of 
    NumericalID k -> "Numerical ID = " ++ (String.fromInt k)
    UUID str -> "UUID = " ++ str

    