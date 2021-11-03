export class KPI {
  public id:number | null;
  public name:string | null;
  public query:string | null;
  public is_deleted = false;

  constructor(id = null,  name = null, query = null, is_deleted = false) {
    this.id = id;
    this.name = name;
    this.query = query;
    this.is_deleted = is_deleted;
  }
}
