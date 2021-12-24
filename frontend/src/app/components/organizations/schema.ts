export class Position {
  public id:number | null;
  public name:string | null;
  public createdAt:string | null;
  public updatedAt:string | null;
  public isApprove = false;
  public _links:any;


  constructor(id = null, name = null, isApprove = false) {
    this.id = id;
    this.name = name;
    this.isApprove = isApprove;
  }
}
