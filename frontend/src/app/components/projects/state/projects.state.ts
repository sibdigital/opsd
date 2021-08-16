interface NationalProject {
  name: string;
}

interface FederalProject {
  name: string;
}

interface ProjectState {
  name: string;
  isPublic?: boolean;
  national_project: NationalProject;
  federal_project: FederalProject;
  projectStatus: string;
  projectApproveStatus: string;
  doneRatio: string;
  requiredDiskSpace: string;
  startDate: Date;
  dueDate: Date;
  items: [];
  startDateCostil?: string;
  endDateCostil?: string;
}

