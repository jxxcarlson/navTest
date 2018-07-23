module Main exposing(..)

import Browser.Navigation
import Browser
import Url
import Browser.Navigation as Nav
import Html exposing(Html)
import Json.Encode
import Html.Attributes 


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
      , sourceText : String 
      , key : Browser.Navigation.Key
   }


init : flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( {   key = key
        , sourceText = "$a^2 + b^2 = c^2$"
        , message = urlMessage url
      } 
      , Cmd.none 
    )



view : Model -> Browser.Document Msg
view model =
  {   title = "Browser.application with math-text (Html msg)"
    , body = [view_ model]
  }

view_ : Model -> Html Msg
view_ model =
  mathText model.sourceText 


mathText : String -> Html msg
mathText content =
    Html.node "math-text"
        [ Html.Attributes.property "content" (Json.Encode.string content) ]
        []


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


-- MSG

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
      Ok urlResult -> urlDataString urlResult 
      Err _ -> "Nothing parseable in URL.  Try one of the links above"


internalUrlMessage url = 
  urlMessage url

externalUrlMessage urlString = 
  "External: url = " ++ urlString

changeUrlMessage url = 
  urlMessage url


-- PARSER


type UrlData = 
    PublicQuery String 
  | PrivateQuery String 
  | NumericalDocumentID Int 
  | DocumentUUID String 


urlPathParser : Parser UrlData
urlPathParser =
  (oneOf [publicQuery, privateQuery, idParser ])

publicQuery : Parser UrlData
publicQuery = 
  succeed PublicQuery 
    |. symbol "/api/public/documents"
    |= queryString

privateQuery : Parser UrlData
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


idParser: Parser UrlData
idParser =  
    succeed identity
      |. symbol "/api/document/"
      |= oneOf [Parser.map NumericalDocumentID int, Parser.map DocumentUUID uuidString]
    


uuid : Parser UrlData
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

urlDataString : UrlData -> String 
urlDataString urlResult = 
  case urlResult of 
    NumericalDocumentID k -> "Numerical document ID: " ++ (String.fromInt k)
    DocumentUUID str -> "Document UUID: " ++ str
    PublicQuery str -> "Public query: " ++ str 
    PrivateQuery str -> "Private query: " ++ str 


    