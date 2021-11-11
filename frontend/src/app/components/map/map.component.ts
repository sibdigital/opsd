import {Component, ElementRef, Input, OnInit, ViewChild} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import XYZ from 'ol/source/XYZ';
import ExtentInteraction from 'ol/interaction/Extent';
import EventType from "ol/events/EventType";
import {shiftKeyOnly} from "ol/events/condition";
import Overlay from "ol/Overlay";
import {Point} from "ol/geom";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import {Feature} from "ol";
import {Circle, Fill, Style} from "ol/style";
import {Draw, Modify, Snap} from "ol/interaction";
import {Layer} from "ol/layer";
import {defaults, FullScreen} from "ol/control";
// import {Coordinate} from 'ol/coordinate';
// import { ScaleLine, defaults as DefaultControls} from 'ol/control';
// import VectorLayer from 'ol/layer/Vector';
// import Projection from 'ol/proj/Projection';
// import {register}  from 'ol/proj/proj4';
// import {Extent} from 'ol/extent';
// import TileLayer from 'ol/layer/Tile';
// import OSM, {ATTRIBUTION} from 'ol/source/OSM';

@Component({
  selector: 'op-map',
  templateUrl: './map.component.html',
  styleUrls: ['./map.component.sass']
})
export class MapComponent implements OnInit {
  coordinate:any;
  overlay:Overlay;
  map:Map;
  points:Point[] = [];
  raster = new TileLayer({
    source: new XYZ({
      url: 'https://{a-c}.tile.openstreetmap.org/{z}/{x}/{y}.png'
    })
  });
  source = new VectorSource({wrapX: false});
  vector = new VectorLayer({
    source: this.source
  });
  @ViewChild('popup') popupElement:ElementRef;
  constructor() {
  }

  ngOnInit():void {
    this.overlay = new Overlay({
      id: 'popup',
      element: this.popupElement.nativeElement,
      autoPan: true,
      autoPanAnimation: {
        duration: 250,
      },
    });
    this.mapInit();
  }

  onMapClick(event:any) {
    console.log(event);
  }

  mapInit() {
    this.map = new Map({
      target: 'map',
      layers: [
        this.raster,
        this.vector
      ],
      overlays: [
        this.overlay,
      ],
      view: new View({
        center: [12137083.654628329, 7004909.695346206],
        zoom: 8,
        extent: [10818697.790765608, 6393413.469064795, 13054327.994050449, 7887910.246096562] // left bottom, right top
      }),
      controls: defaults().extend([new FullScreen()]),
    });
    this.map.addEventListener('singleclick', (event) => {
      this.coordinate = event.coordinate;
      this.overlay.setPosition(this.coordinate);
      this.points.push(new Point(this.coordinate));
    });
    this.map.addInteraction(new ExtentInteraction({
      condition: shiftKeyOnly
    }));
    this.map.addInteraction(new Draw({
      source: this.source,
      type: 'Point'
    }));
    this.map.addInteraction(new Snap({
      source: this.source
    }));
    this.map.addInteraction(new Modify({
      source: this.source
    }));
  }

  closePopup(element:HTMLAnchorElement) {
    this.overlay.setPosition(undefined);
    element.blur();
  }
}
DynamicBootstrapper.register({selector: 'op-map', cls: MapComponent});
