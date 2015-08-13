/*******************************************************************************
 * Copyright 2012-2014 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/

import QtQuick 2.2
import ArcGIS.Runtime 10.3

Item {
    QtObject{
        id: pp
        property Map map: null
        property double xMinTR
        property double yMinTR
        property double xMaxTR
        property double yMaxTR
        property var polyGraphic
        property bool turnedMagnifyOff
    }

    property bool addCornerPointsGraphics: true
    property color aoiBorderColor: "red"
    property int aoiBorderWidth: 1
    property color aoiFillColor: "transparent"
    property bool isDrawingAOI: false

    Component.onCompleted: {
        if (!pp.map && parent && parent.objectType && parent.objectType === "Map") {
            pp.map = parent;
            pp.map.addLayer(aoiLayer);
        }
    }

    Connections{
        target: pp.map
        onMousePressAndHold: {
            if(isDrawingAOI) {
                pp.map.magnifierOnPressAndHoldEnabled = false;
                pp.turnedMagnifyOff = true;

                mouse.accepted = false;

                aoiLayer.removeAllGraphics();

                pp.xMinTR = mouse.mapX;
                pp.yMaxTR = mouse.mapY;
                pp.xMaxTR = mouse.mapX;
                pp.yMinTR= mouse.mapY;

                pp.polyGraphic = aoiGraphic.clone();
                pp.polyGraphic.geometry = aoiPolygon;
                aoiLayer.addGraphic(pp.polyGraphic);

                if (addCornerPointsGraphics){
                    var startPoint = ptCloner.clone();
                    startPoint.geometry = mouse.mapPoint;
                    aoiLayer.addGraphic(startPoint);
                }
            }
        }

        onMousePositionChanged: {
            if (isDrawingAOI) {
                pp.xMaxTR = mouse.mapX;
                pp.yMinTR = mouse.mapY;
                pp.polyGraphic.geometry = aoiPolygon;
            }
        }

        onMouseReleased: {
            if (isDrawingAOI){
                pp.xMaxTR = mouse.mapX;
                pp.yMinTR = mouse.mapY;

                if (isDrawingAOI){
                    if (addCornerPointsGraphics){
                        var finishPoint = ptCloner.clone();
                        finishPoint.geometry = mouse.mapPoint;
                        aoiLayer.addGraphic(finishPoint);

                    }
                    isDrawingAOI = false;
                }
                if (pp.turnedMagnifyOff){
                    pp.map.magnifierOnPressAndHoldEnabled = true;
                    pp.turnedMagnifyOff = true;
                }
            }
        }
    }

    Polygon {
        id: aoiPolygon
        json: {"rings" : [[ [pp.xMinTR,pp.yMaxTR], [pp.xMaxTR,pp.yMaxTR], [pp.xMaxTR,pp.yMinTR], [pp.xMinTR,pp.yMinTR] ]]}
    }

    GraphicsLayer {
        id: aoiLayer
    }

    Graphic {
        id: aoiGraphic
        symbol: SimpleFillSymbol {
            color: aoiFillColor
            style: Enums.SimpleFillSymbolStyleSolid

            outline:  SimpleLineSymbol {
                color: aoiBorderColor
                width: aoiBorderWidth
            }
        }
    }

    Graphic {
        id: ptCloner
        symbol:  SimpleMarkerSymbol {
            color: "blue"
            size: 14
            style: Enums.SimpleMarkerSymbolStyleDiamond
        }
    }
}
