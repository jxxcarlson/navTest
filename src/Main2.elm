import Browser.Navigation
import Browser
import Url
import Html exposing(Html)

import Element exposing (..)
import Element.Font as Font


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
        , message = "Initial data: url, path = " ++ url.path ++ ", " ++ (url.query |> Maybe.withDefault "")
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
                   , Element.el [] (text model.message)
                ]
    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of 
    Zilch -> 
      ( {model | counter = model.counter + 1}, Cmd.none )
    HandleUrlRequest r -> 
       case r of 
         Browser.Internal url -> ({model | message = "Internal url request: url, path = " ++ url.path ++ ", " ++ (url.query |> Maybe.withDefault "")}, Cmd.none)
         Browser.External urlString -> ({model | message = "External url request: " ++ urlString }, Cmd.none)
    UrlChange url ->
        ({model | message = "UrlChange: url, path = " ++ url.path ++ ", " ++ (url.query |> Maybe.withDefault "")}, Cmd.none)
        

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