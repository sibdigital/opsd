export interface ProjectsTableSelectedFilter {
  selected: boolean,
  title: string,
  value: string,
}

export interface ProjectsTableFilters {
  name?: string;
  identifier?: string;
  start_date?: Date;
  due_date?: Date;
  national_project_id?: number;
  project_status_id?: number;
  federal_project_id?: number;
  project_approve_status_id?: number;
  status?: number;
  updated_on?: Date;
  created_on?: Date;
}
