import {Component, ElementRef, Input, OnInit, ViewChild} from "@angular/core";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import XYZ from 'ol/source/XYZ';
import Overlay from "ol/Overlay";
import {Point} from "ol/geom";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import {defaults as defaultControls} from "ol/control";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {GeographicMap, MapPoint, Permission} from "core-components/map/schema";
import {Feature} from "ol";
import {Circle, Fill, Stroke, Style, Text} from "ol/style";
import {defaults as defaultInteractions, Draw} from "ol/interaction";
import {MatDialog} from "@angular/material/dialog";
import {SelectWorkPackageDialog} from "core-components/map/select-work-package-dialog/select-work-package-dialog";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import CircleStyle from "ol/style/Circle";

@Component({
  selector: 'op-map',
  templateUrl: './map.component.html',
  styleUrls: ['./map.component.sass']
})
export class MapComponent implements OnInit {
  coordinate:any;
  selectedPoint:Partial<MapPoint> = {};
  mapPointForm:Partial<MapPoint>;
  infoPopupOverlay:Overlay;
  addPopupOverlay:Overlay;
  map:Map;
  mapData:GeographicMap;
  points:Point[] = [];
  raster = new TileLayer({
    source: new XYZ({
      url: 'https://{a-c}.tile.openstreetmap.org/{z}/{x}/{y}.png'
    })
  });
  source = new VectorSource({wrapX: false});
  vector = new VectorLayer({
    source: this.source,
    style: new Style({
      image: new Circle({
        radius: 5,
        fill: new Fill({color: 'red'})
      })
    })
  });
  isDeleted = false;
  drawInteraction = new Draw({
    source: this.source,
    type: 'Point'
  });
  public $element:JQuery;
  @Input() projectId:string;
  @ViewChild('infoPopup') infoPopupElement:ElementRef;
  @ViewChild('addPopup') addPopupElement:ElementRef;
  workPackage:any = null;
  descriptionValue:string = '';
  userPermittedTo = {view: false, edit: false};
  project:any;
  titleValue:string = '';
  pointStyle = new CircleStyle({
    radius: 5,
    fill: new Fill({
      color: '#ff0000'
    }),
    stroke: new Stroke({
      color: '#8e0000',
      width: 1
    })
  });

  constructor(protected pathHelper:PathHelperService,
              protected httpClient:HttpClient,
              protected elementRef:ElementRef,
              protected dialog:MatDialog,
              private notificationService:NotificationsService) {
  }

  ngOnInit():void {
    this.$element = jQuery(this.elementRef.nativeElement);
    this.projectId = this.$element.attr('projectId')!;
    this.infoPopupOverlay = new Overlay({
      id: 'info-popup',
      element: this.infoPopupElement.nativeElement,
      autoPan: true,
      autoPanAnimation: {
        duration: 250,
      },
    });
    this.addPopupOverlay = new Overlay({
      id: 'add-popup',
      element: this.addPopupElement.nativeElement,
      autoPan: true,
      autoPanAnimation: {
        duration: 250,
      },
    });
    this.checkPermissions();
    this.getMaps();
    this.getProject();
  }

  getMaps() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/geographicMaps/search/findAllByProject_Id',
      {
        params: new HttpParams()
          .set("projectId", this.projectId)
      })
      .toPromise()
      .then((maps:any) => {
        this.mapData = maps._embedded.geographicMaps[0];
        if (this.mapData) {
          this.getMapPoints();
        }
      })
      .catch((reason) => console.error(reason));
  }


  getMapPoints() {
    this.httpClient.get(
      this.pathHelper.javaApiPath.javaApiBasePath + '/mapPoints/search/findAllByIsDeletedFalseAndGeographicMap_Id',
      {
        params: new HttpParams()
          .set("geographicMapId", this.mapData.id ? this.mapData.id.toString() : '')
          .set("projection", "mapPointProjection")
      })
      .toPromise()
      .then((map_points:any) => {
        this.mapData.mapPoints = map_points._embedded.mapPoints;
        this.mapInit();
      })
      .catch((reason) => console.error(reason));
  }

  mapInit() {
    const features = new Array(this.mapData.mapPoints.length);
    this.mapData.mapPoints.forEach((mapPoint, i) => {
      features[i] = new Feature({
        geometry: new Point([mapPoint ? mapPoint.longitude : 1, mapPoint ? mapPoint.latitude : 1]),
        class: 'red',
        info: mapPoint
      });
      features[i].setStyle(new Style({
        image: this.pointStyle,
        text: this.textStyle(mapPoint.title.toString())
      }));
    });
    this.vector.setSource(new VectorSource({
      features: features,
    }));
    this.vector.setStyle(new Style({
      fill: new Fill({color: 'rgba(255, 0, 0, 0.1)'}),
      stroke: new Stroke({color: 'red', width: 1})
    }));
    this.map = new Map({
      target: 'map',
      layers: [
        this.raster,
        this.vector
      ],
      overlays: [
        this.infoPopupOverlay,
        this.addPopupOverlay
      ],
      view: new View({
        center: [12137083.654628329, 7004909.695346206],
        zoom: 8,
        extent: [10818697.790765608, 6393413.469064795, 13054327.994050449, 7887910.246096562] // left bottom, right top
      }),
      controls: defaultControls().extend([]),
      interactions: defaultInteractions({
        doubleClickZoom: false
      })
    });
    this.map.addEventListener('singleclick', (event) => {
      this.map.forEachFeatureAtPixel(event.pixel, (feature) => {
        const coordinate = (<Point>feature.getGeometry()).getCoordinates();
        this.selectedPoint = feature.getProperties().info;
        this.infoPopupOverlay.setPosition(coordinate);
      });
    });
  }

  closePopup(popup:any) {
    popup.setPosition(undefined);
  }

  addNewPoint() {
    this.map.addInteraction(this.drawInteraction);
    this.map.once('dblclick', (event) => {
      this.coordinate = event.coordinate;
      this.addPopupOverlay.setPosition(this.coordinate);
      this.map.removeInteraction(this.drawInteraction);
    });
  }

  chooseWorkPackage() {
    const dialogRef = this.dialog.open(SelectWorkPackageDialog, {data: {project: this.project}});
    dialogRef.afterClosed().subscribe(result => {
      this.workPackage = result;
    });
  }

  openUpdatePoint() {
    const position = this.infoPopupOverlay.getPosition();
    this.closePopup(this.infoPopupOverlay);
    this.addPopupOverlay.setPosition(position);
    this.descriptionValue = this.selectedPoint.description ? this.selectedPoint.description : '';
    this.titleValue = this.selectedPoint.title ? this.selectedPoint.title : '';
    this.workPackage = this.selectedPoint.workPackage;
    this.mapPointForm = this.selectedPoint;
  }

  deletePoint() {
    const deletedPoint = new MapPoint(this.selectedPoint.id ? this.selectedPoint.id : null,
      this.selectedPoint.title ? this.selectedPoint.title : '',
      this.selectedPoint.longitude ? this.selectedPoint.longitude : 0,
      this.selectedPoint.latitude ? this.selectedPoint.latitude : 0,
      this.selectedPoint.description ? this.selectedPoint.description : '',
      true,
      this.project._links.self.href,
      this.workPackageHref(this.selectedPoint.workPackage),
      this.mapData._links.self.href);
    this.httpClient.post(this.pathHelper.javaApiPath.javaApiBasePath + '/mapPoints', deletedPoint,
      {params: new HttpParams().set('projection', 'mapPointProjection')})
      .toPromise()
      .then((mapPoint:MapPoint) => {
        this.closePopup(this.infoPopupOverlay);
        this.vector.getSource().removeFeature(this.vector.getSource()
          .getFeaturesAtCoordinate([mapPoint.longitude, mapPoint.latitude])[0]);
        this.notificationService.addSuccess('Изменения сохранены');
        this.clearForm();
      })
      .catch((reason) => {
        this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
        console.error(reason);
      });
  }

  workPackageHref(workPackage:any) {
    if (workPackage) {
      if (workPackage._links) {
        return workPackage._links.self.href;
      } else {
        return this.pathHelper.javaApiPath.javaApiBasePath + `/workPackages/${workPackage.id}`;
      }
    } else {
      return null;
    }
  }

  updatePoint() {
    const upMapPoint = new MapPoint(this.mapPointForm.id ? this.mapPointForm.id : null,
      this.titleValue ? this.titleValue : '',
      this.mapPointForm.longitude ? this.mapPointForm.longitude : 0,
      this.mapPointForm.latitude ? this.mapPointForm.latitude : 0,
      this.descriptionValue,
      this.mapPointForm.deleted ? this.mapPointForm.deleted : false,
      this.project._links.self.href,
      this.workPackageHref(this.workPackage),
      this.mapData._links.self.href);
    this.httpClient.post(this.pathHelper.javaApiPath.javaApiBasePath + '/mapPoints', upMapPoint,
      {params: new HttpParams().set('projection', 'mapPointProjection')})
      .toPromise()
      .then((mapPoint:MapPoint) => {
        const index = this.mapData.mapPoints.findIndex(item => item.id === mapPoint.id);
        this.mapData.mapPoints[index] = mapPoint;
        const feature = this.vector.getSource().getFeaturesAtCoordinate([mapPoint.longitude, mapPoint.latitude])[0];
        feature.setProperties({info: mapPoint});
        feature.setStyle(new Style({
          image: this.pointStyle,
          text: this.textStyle(mapPoint.title.toString())
        }));
        this.notificationService.addSuccess('Изменения сохранены');
        this.closePopup(this.addPopupOverlay);
        this.clearForm();
      })
      .catch((reason) => {
        this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
        console.error(reason);
      });
  }

  createPoint() {
  const newMapPoint = new MapPoint(null, this.titleValue, this.coordinate[0], this.coordinate[1],
    this.descriptionValue, this.isDeleted,
    this.project._links.self.href,
    this.workPackage ? this.workPackage._links.self.href : null,
    this.mapData._links.self.href);
    this.httpClient.post(this.pathHelper.javaApiPath.javaApiBasePath + '/mapPoints', newMapPoint,
      {params: new HttpParams().set('projection', 'mapPointProjection')})
      .toPromise()
      .then((mapPoint:MapPoint) => {
        this.mapData.mapPoints.push(mapPoint);
        const newFeature = new Feature({
          geometry: new Point([mapPoint ? mapPoint.longitude : 1, mapPoint ? mapPoint.latitude : 1]),
          class: 'red',
          info: mapPoint
        });
        newFeature.setStyle(new Style({
          image: this.pointStyle,
          text: this.textStyle(mapPoint.title.toString())
        }));
        this.vector.getSource()
          .addFeature(newFeature);
        this.notificationService.addSuccess('Изменения сохранены');
        this.closePopup(this.addPopupOverlay);
        this.clearForm();
      })
      .catch((reason) => {
        this.notificationService.addError(`Ошибка сохранения: ${reason.message}`);
        console.error(reason);
      });
  }

  private checkPermissions() {
    this.httpClient.get(
      this.pathHelper.javaUrlPath + '/user/isPermittedTo',
      {
        params: new HttpParams()
          .set('projectId', this.projectId.toString())
          .set('permissions', 'view_map, edit_map')
      })
      .toPromise()
      .then((permissions:Permission[]) => {
        const viewPermission = permissions.find(item => {
          return item.permission === 'view_map';
        });
        const editPermission = permissions.find(item => {
          return item.permission === 'edit_map';
        });
        this.userPermittedTo.view = viewPermission ? viewPermission.is_exist : false;
        this.userPermittedTo.edit = editPermission ? editPermission.is_exist : false;
      })
      .catch((reason) => console.error(reason));
  }

  createMap() {
    this.mapData = new GeographicMap(null, false, this.project._links.self.href);
    this.httpClient.post(this.pathHelper.javaApiPath.javaApiBasePath + '/geographicMaps', this.mapData,
      {
        params: new HttpParams()
          .set('projection', 'geographicMapProjection')
      })
      .toPromise()
      .then((map:GeographicMap) => {
        this.mapData = map;
        if (this.mapData) {
          this.getMapPoints();
        }
      })
      .catch((reason) => console.error(reason));
  }

  private getProject() {
    this.httpClient.get(this.pathHelper.javaApiPath.javaApiBasePath + '/projects/' + this.projectId).toPromise()
      .then((project:any) => {
        this.project = project;
      })
      .catch((reason) => console.error(reason));
  }

  savePoint() {
    console.log(this.mapPointForm);
    this.mapPointForm ? this.updatePoint() : this.createPoint();
  }

  textStyle(title:string) {
    return new Text({
      text: title.length <= 15 ? title : `${title.substring(0, 10)}...`,
      offsetY: 10,
      scale: 1.2,
      fill: new Fill({
        color: '#000'
      }),
      stroke: new Stroke({
        color: '#fff',
        width: 1
      })
    });
  }

  clearForm() {
    this.workPackage = null;
    this.descriptionValue = '';
    this.titleValue = '';
    this.mapPointForm = {};
  }
}

DynamicBootstrapper.register({selector: 'op-map', cls: MapComponent});
