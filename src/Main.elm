module Main exposing(..)

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
        message : String
      , key : Browser.Navigation.Key
   }

init : flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( {   key = key
        , message = urlMessage url
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
                [   Element.el [Font.bold] (text "Try the links below.")
                  
                   , Element.link  [Font.color (Element.rgb 0 0 1)]
                        { url = "/api/public/documents?author=twain"
                        , label = text "Internal link: /api/public/documents?author=twain"
                        }
                    , Element.link  [Font.color (Element.rgb 0 0 1)]
                        { url = "http://localhost:8080/api/document/123"
                        , label = text "External link: http://localhost:8080/api/document/123"
                        }

                    , Element.link  [Font.color (Element.rgb 0 0 1)]
                        { url = "http://localhost:8080/api/document/jxxcarlson.foobar"
                        , label = text "External link: http://localhost:8080/api/document/jxxcarlson.foobar"
                        }

                    , Element.link  [Font.color (Element.rgb 0 0 1)]
                        { url = "http://localhost:8080/api/documents?author=twain"
                        , label = text "External link: http://localhost:8080/api/documents?author=twain"
                        }

                    , Element.link  [Font.color (Element.rgb 0 0 1)]
                        { url = "http://localhost:8080/api/public/documents?author=twain"
                        , label = text "External link: http://localhost:8080/api/public/documents?author=twain"
                        }

                    , Element.el [] (text model.message)
                ]
    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of 
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
      HandleUrlRequest Browser.UrlRequest
    | UrlChange Url.Url

-- HELPERS 

urlMessage url = 
  let 
    pathAndQuery =
      case url.query of 
        Nothing -> url.path 
        Just query -> url.path ++ "?" ++ query
  in 
    case (Parser.run urlPathParser pathAndQuery) of 
      Ok urlResult -> urlResultString urlResult 
      Err _ -> "Nothing parseable in URL.  Try one of the links above"


internalUrlMessage url = 
  urlMessage url

externalUrlMessage urlString = 
  "External: url = " ++ urlString

changeUrlMessage url = 
  urlMessage url


-- PARSER


type UrlResult = 
    PublicQuery String 
  | PrivateQuery String 
  | NumericalDocumentID Int 
  | DocumentUUID String 

urlPathParser : Parser UrlResult
urlPathParser =
  (oneOf [publicQuery, privateQuery, idParser ])

publicQuery : Parser UrlResult
publicQuery = 
  succeed PublicQuery 
    |. symbol "/api/public/documents"
    |= queryString

privateQuery : Parser UrlResult
privateQuery = 
  succeed PrivateQuery 
    |. symbol "/api/documents"
    |= queryString


queryString : Parser String
queryString = 
  Parser.map (String.dropLeft 1) (getChompedString <|
    succeed ()
      |. chompIf (\char -> char == '?') 
      |. chompWhile isQueryChar
  )

isQueryChar : Char -> Bool
isQueryChar char =
  Char.isAlpha char|| Char.isDigit char ||  char == '=' ||  char == '&'


idParser: Parser UrlResult
idParser =  
    succeed identity
      |. symbol "/api/document/"
      |= oneOf [Parser.map NumericalDocumentID int, Parser.map DocumentUUID uuidString]
    


uuid : Parser UrlResult
uuid = 
  succeed DocumentUUID
    |. symbol "/api/document/"
    |= uuidString 

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

urlResultString : UrlResult -> String 
urlResultString urlResult = 
  case urlResult of 
    NumericalDocumentID k -> "Numerical document ID: " ++ (String.fromInt k)
    DocumentUUID str -> "Document UUID: " ++ str
    PublicQuery str -> "Public query: " ++ str 
    PrivateQuery str -> "Private query: " ++ str 


    