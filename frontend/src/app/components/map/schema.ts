export class GeographicMap {
  public id:number | null;
  public deleted = false;
  public project:any;
  public mapPoints:MapPoint[];
  public _links:any;

  constructor(id:number | null, deleted:boolean, project:any, mapPoints:MapPoint[] = []) {
    this.id = id;
    this.deleted = deleted;
    this.project = project;
    this.mapPoints = mapPoints;
  }
}

export class MapPoint {
  public id:number | null;
  public title:string;
  public longitude:number;
  public latitude:number;
  public description:string;
  public deleted = false;
  public project:any;
  public workPackage:any;
  public geographicMap:any;

  constructor(id:number | null, title:string, longitude:number, latitude:number, description:string, deleted:boolean, project:any, workPackage:any, map:any) {
    this.id = id;
    this.title = title;
    this.longitude = longitude;
    this.latitude = latitude;
    this.description = description;
    this.deleted = deleted;
    this.project = project;
    this.workPackage = workPackage;
    this.geographicMap = map;
  }
}

export class Permission {
  public permission:string;
  public is_exist:boolean;
  constructor(permission:string, is_exist:boolean) {
    this.permission = permission;
    this.is_exist = is_exist;
  }
}
