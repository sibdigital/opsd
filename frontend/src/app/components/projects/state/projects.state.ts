export interface INationalProject {
  name: string;
  leader: string;
  leaderPosition: string;
  type: string;
  parentId: string;
  curator: string;
  curatorPosition: string;
  startDate: Date;
  dueDate: Date;
  description: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface IFederalProject extends INationalProject {
}

export interface IProjectsState {
  id: number;
  status: number;
  name: string;
  public: boolean;
  description?: string;
  national_project: INationalProject;
  federal_project: IFederalProject;
  projectStatus: string;
  projectApproveStatus: string;
  doneRatio: string;
  requiredDiskSpace: string;
  startDate: Date;
  dueDate: Date;
  identifier: string;
  isExpand?: boolean;
  isOpenMenu?: boolean;
}


export interface IProjectsTableColumn {
  id: string;
  name: string;
}

export const DefaultProjectsColumnsTable: IProjectsTableColumn[] = [
  {
    id: 'name',
    name: 'НАИМЕНОВАНИЕ',
  },
  {
    id: 'public',
    name: 'ОБЩИЙ',
  },
  {
    id: 'nationalProject',
    name: 'НАЦ.ПРОЕКТ',
  },
  {
    id: 'projectStatus',
    name: 'СТАТУС',
  },
  {
    id: 'projectApproveStatus',
    name: 'ЭТАП СОГЛАСОВАНИЯ',
  },
  {
    id: 'doneRatio',
    name: 'ПРОЦЕНТ ИСПОЛНЕНИЯ',
  },
  // {
  //   id: 'requiredDiskSpace',
  //   name: 'ТРЕБУЕТСЯ МЕСТО НА ДИСКЕ',
  // },
  {
    id: 'startDate',
    name: 'ДАТА НАЧАЛА',
  },
  {
    id: 'dueDate',
    name: 'ДАТА ОКОНЧАНИЯ',
  },
  {
    id: 'expandAll',
    name: 'РАЗВЕРНУТЬ ВСЕ',
  }
];

export interface IProjectsPaginationFromJOPSDAPI {
  size: number; // elements per page
  totalElements: number;
  totalPages: number;
  number: number; // number of current page
}

export interface IProjectsPaginationState extends IProjectsPaginationFromJOPSDAPI {
}

export const DefaultProjectsPaginationState: IProjectsPaginationState = Object.freeze({
  size: 25,
  totalElements: 0,
  totalPages: 0,
  number: 0,
})
