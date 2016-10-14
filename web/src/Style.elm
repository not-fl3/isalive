module Style exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

mainContainerStyle : Attribute a
mainContainerStyle =
    style [ ("margin-top", "0px")
          , ("width", "900px")
          , ("height", "600px") ]

contentColStyle : Attribute a
contentColStyle =
    style [("padding-top", "20%")]

tableDivStyle : Attribute a
tableDivStyle =
    style [ ("padding-left", "50px")
          , ("margin-top", "30px")
          , ("height", "150px")]

imageColStyle : Attribute a
imageColStyle = style [("margin-left", "-5%")]

footerStyle : Attribute a
footerStyle = style [("bottom", "0"), ("position", "absolute")]

loadingImgStyle : Attribute a
loadingImgStyle =
  style
    [ ("position", "absolute")
    , ("height", "90px")
    , ("left", "50%")
    , ("top", "50%")
    , ("margin-left", "-45px")
    , ("margin-top", "-45px")
    ]

projectDescriptionStyle : Attribute a
projectDescriptionStyle =
    style
        [ ("position", "relative")
        , ("color", "red")
        , ("margin-left", "10%")
        , ("top", "20%")
        , ("font-family", "molot")
        , ("font-size", "20px")
        ]

projectFooterStyle : Attribute a
projectFooterStyle =
    style
        [ ("position", "relative")
        , ("color", "red")
        , ("margin-left", "10%")
        , ("top", "55%")
        , ("font-family", "molot")
        , ("font-size", "30px")
        ]

projectNameFontStyle : Attribute a
projectNameFontStyle =
    style
        [ ("color", "red")
        , ("font-size", "72px")
        , ("font-family", "molot")
        ]

backImgStyle : Attribute a
backImgStyle =
    style
        [ ("height", "400px")
        , ("margin-top", "130px")
        ]
