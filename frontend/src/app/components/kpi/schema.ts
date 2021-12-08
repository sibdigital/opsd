export class KPI {
  public id:number | null;
  public name:string | null;
  public query:string | null;
  public is_deleted = false;
  public _links:any;

  constructor(id = null,  name = null, query = null, is_deleted = false) {
    this.id = id;
    this.name = name;
    this.query = query;
    this.is_deleted = is_deleted;
  }
}

export class KPIVariable {
  public id:number | null;
  public name:string | null;
  public value:string | null;
  public is_deleted = false;
  public _links:any;

  constructor(id = null,  name = null, value = null, is_deleted = false) {
    this.id = id;
    this.name = name;
    this.value = value;
    this.is_deleted = is_deleted;
  }
}

export interface KpiDto {
  kpi:KPI;
  kpiVariables:KPIVariable[];
}
