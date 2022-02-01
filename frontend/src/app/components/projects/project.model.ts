export class Project {
  id:number = 0;
  name:string = '';
  description:string = '';
  public:boolean = true;
  parent:any = null;
  createdOn:string | null = null;
  updatedOn:string | null = null;
  identifier:string | null = null;
  status:number = 1;
  lft:number | null = null;
  rgt:number | null = null;
  projectApproveStatus:any = null;
  projectStatus:any = null;
  startDate:string | null = null;
  dueDate:string | null = null;
  nationalProject:any = null;
  federalProject:any = null;
  type:string | null = null;
  factStartDate:string | null = null;
  factDueDate:string | null = null;
  investAmount:number | null = null;
  program:boolean | null = null;
  address:number | null = null;
  nationalProjectTarget:string | null = null;
  governmentProgram:string | null = null;
  missionOfHead:string | null = null;
}
