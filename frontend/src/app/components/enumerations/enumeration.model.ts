import {Project} from "core-components/projects/project.model";

export class Enumeration {
  id:number = 0;
  name:string | null = null;
  position:number | null = null;
  isDefault:boolean | null = null;
  type:number | null = null;
  active:boolean | null = null;
  project:Project | null = null;
  parent:any = null;
  createdAt:string | null = null;
  updatedAt:string | null = null;
  color:any = null;
}
