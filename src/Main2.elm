import Browser.Navigation
import Browser
import Url
import Html exposing (text, a, p)
import Html.Attributes exposing (href)

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
        , message = "Initial data: url,path = " ++ url.path ++ ", " ++ (url.query |> Maybe.withDefault "")
      } 
      , Cmd.none 
    )

view : Model -> Browser.Document msg
view model =
      Browser.Document "Hi" [ 
          a [href "/yo?yada=no"] [text <| "Link" ]
          , p [] [text (model.message)] ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of 
     Zilch -> 
      ( {model | counter = model.counter + 1}, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest r =    
    Debug.log "url request" r
        |> always Zilch


onUrlChange : Url.Url -> Msg
onUrlChange u =
    Debug.log "url change" u
        |> always Zilch

type Msg = Zilch