import {Component, Injector, OnInit} from "@angular/core";
import {States} from "core-components/states.service";
import {StateService} from "@uirouter/core";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {PaginationService} from "core-components/table-pagination/pagination-service";
import {HttpClient, HttpHeaders} from "@angular/common/http";
import {DatePipe} from "@angular/common";
import {QueryColumn} from "core-components/wp-query/query-column";
import {IFederalProject, INationalProject, IProjectsState} from "core-components/projects/state/projects.state";

export const projectsSelector = 'projects';

const TestProjects: IProjectsState[] = [
  {
    name: '«Обеспечение качественно нового уровня развития инфраструктуры культуры» «Культурная среда» в Бурятии',
    national_project: { name: 'Культура' } as INationalProject,
    federal_project: { name: 'Культурная среда' } as IFederalProject,
    projectStatus: 'не начат',
    projectApproveStatus: 'инициирован',
    doneRatio: '7.00',
    requiredDiskSpace: '250 кБ',
    startDate: new Date(2019, 0, 1),
    dueDate: new Date(2024, 11, 31),
    identifier: 'q',
    public: false,
  },
  {
    name: 'Переселение жителей микрорайонов «УМТС - Икибзяк» и «Механизированная колонна – 136» поселка Таксимо, Муйского района.',
    national_project: {  } as INationalProject,
    federal_project: {  } as IFederalProject,
    projectStatus: 'не начат',
    projectApproveStatus: 'инициирован',
    doneRatio: '0.00',
    requiredDiskSpace: '',
    startDate: new Date(2019, 0, 1),
    dueDate: new Date(2024, 11, 31),
    identifier: 'q',
    public: false,
  },
  {
    name: 'Формирование комфортной городской среды.',
    national_project: { name: 'Жильё и городская среда' } as INationalProject,
    federal_project: { name: 'Жилье' } as IFederalProject,
    projectStatus: 'не начат',
    projectApproveStatus: 'инициирован',
    doneRatio: '50.00',
    requiredDiskSpace: '',
    startDate: new Date(2019, 0, 1),
    dueDate: new Date(2024, 11, 31),
    identifier: 'q',
    public: false,
  }
];

interface IColumn {
  id: string;
  name: string;
}

const ColumnsTable: IColumn[] = [
  {
    id: 'name',
    name: 'НАИМЕНОВАНИЕ',
  },
  {
    id: 'isPublic',
    name: 'ОБЩИЙ',
  },
  {
    id: 'nationalProject',
    name: 'НАЦ.ПРОЕКТ',
  },
  {
    id: 'status',
    name: 'СТАТУС',
  },
  {
    id: 'approveStatus',
    name: 'ЭТАП СОГЛАСОВАНИЯ',
  },
  {
    id: 'doneRatio',
    name: 'ПРОЦЕНТ ИСПОЛНЕНИЯ',
  },
  {
    id: 'requiredDiskSpace',
    name: 'ТРЕБУЕТСЯ МЕСТО НА ДИСКЕ',
  },
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

interface IPaginationLinks {
  name: number;
  active: boolean;
}

@Component({
  selector: projectsSelector,
  templateUrl: './projects.html',
  styleUrls: ['./projects.sass'],
})
export class ProjectsComponent implements OnInit {

  public projects: IProjectsState[];
  public requiredDiskPlace = '3 проекта используют 250 кБ дискового пространства';
  public page: number;
  public count: number;
  public total: number;
  public pages: number;
  public perPages: IPaginationLinks[];
  public columns: IColumn[];
  public colArr: QueryColumn[];

  constructor(
    public datepipe: DatePipe,
    private http: HttpClient,
    public injector:Injector,
    public states:States,
    readonly $state:StateService,
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    public paginator: PaginationService,
  ) { }

  ngOnInit():void {
    console.dir({States: this.states, StateService: this.$state});
    this.page = 1;
    this.count = 3;
    this.total = 3;
    this.columns = ColumnsTable;

    this.projects = TestProjects.map((project) => {
      // project.startDateCostil = [project.startDate.getDate(), project.startDate.getMonth() + 1, project.startDate.getFullYear()].join('.');
      // project.endDateCostil = [project.dueDate.getDate(), project.dueDate.getMonth() + 1, project.dueDate.getFullYear()].join('.');
      return project;
    });

    this.perPages = [{name: 20, active: true} as IPaginationLinks, {name: 100, active: false} as IPaginationLinks];

    // this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.javaApi.projects.toString())
    //   .toPromise()
    //   .then((projects: CollectionResource<HalResource>) => {
    //     console.dir({projects});
    //     let total: number = projects.total;
    //     let pageSize: number = projects.pageSize;
    //     let remainder = total % pageSize;
    //     this.pages = (total - remainder) / pageSize;
    //     if (remainder !== 0) {
    //       this.pages++;
    //     }
    //     console.dir({total, pageSize, remainder, pages: this.pages});
    //     projects.elements.forEach((el: HalResource) => {
    //       console.dir({element: el});
    //     });
    //     // this.projects = projects.elements.sort((a, b) => (a.name > b.name ? 1 : -1)).map((el:HalResource) => {
    //     // console.dir({ element: el });
    //     // return el as unknown as ProjectState;
    //     //   return {
    //     //     name: el.name,
    //     //     isPublic: el.is_public,
    //     //     national_project: el.national_project,
    //     //     federal_project: el.federal_project,
    //     //     projectStatus: el.projectStatus,
    //     //     projectApproveStatus: el.projectApproveStatus,
    //     //     doneRatio: el.doneRatio,
    //     //     requiredDiskSpace: el.requiredDiskSpace,
    //     //     startDate: el.startDate,
    //     //     dueDate: el.dueDate,
    //     //     items: el.items,
    //     //   } as ProjectState;
    //     // });
    //     // const requests = projects.elements.sort((a, b) => (a.name > b.name ? 1 : -1)).map((el:HalResource) => el);
    //
    //     // console.dir({ projects: this.projects, request: requests });
    //     // requests.forEach((request) => {
    //     //   request.$load();
    //     //   console.dir({ state: request.state });
    //     // });
    //   })
    //   .catch(function (reason) {
    //     console.log(reason);
    //   });

    // this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.javaApi.projects.toString())
    //   .toPromise()
    //   .then((projects: CollectionResource<HalResource>) => {
    //     console.dir({ response: projects });
    //     if (_.isArray(projects.source)) {
    //       let arr: ProjectState[] = [];
    //       projects.source.forEach((project) => {
    //         const startDate = project.startDate ? new Date(project.startDate) : null;
    //         const dueDate = project.dueDate ? new Date(project.dueDate) : null;
    //
    //         arr.push({
    //           name: project.name,
    //           national_project: { name: 'Культура' } as INationalProject,
    //           federal_project: { name: 'Культурная среда' } as IFederalProject,
    //           projectStatus: 'не начат',
    //           projectApproveStatus: 'инициирован',
    //           doneRatio: '7.00',
    //           requiredDiskSpace: '250 кБ',
    //           startDate: startDate,
    //           startDateCostil: startDate ? this.datepipe.transform(startDate, 'dd.MM.yyyy') : '',
    //           dueDate: dueDate,
    //           endDateCostil: dueDate ? this.datepipe.transform(dueDate, 'dd.MM.yyyy') : '',
    //           items: [],
    //         } as ProjectState);
    //       });
    //       this.projects = arr;
    //     }
    //   })
    //   .catch((reason) => console.log(reason));

    // this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects.toString())
    //   .toPromise()
    //   .then((projects:CollectionResource<HalResource>) => {
    //     this.projects = projects.elements.sort((a, b) => (a.name > b.name ? 1 : -1)).map((el:HalResource) => {
    //       // console.dir({ element: el });
    //       // return el as unknown as ProjectState;
    //       return {
    //         name: el.name,
    //         isPublic: el.is_public,
    //         national_project: el.national_project,
    //         federal_project: el.federal_project,
    //         projectStatus: el.projectStatus,
    //         projectApproveStatus: el.projectApproveStatus,
    //         doneRatio: el.doneRatio,
    //         requiredDiskSpace: el.requiredDiskSpace,
    //         startDate: el.startDate,
    //         dueDate: el.dueDate,
    //         items: el.items,
    //       } as ProjectState;
    //     });
    //     const requests = projects.elements.sort((a, b) => (a.name > b.name ? 1 : -1)).map((el:HalResource) => el);
    //
    //     console.dir({ projects: this.projects, request: requests });
    //     requests.forEach((request) => {
    //       request.$load();
    //       console.dir({ state: request.state });
    //     });
    //   })
    //   .catch(function (reason) {
    //     console.log(reason);
    //   });
  }

  public getNewPage(event: any) {
    console.dir({ event, type: typeof event });
    console.log('getNewPage');
  }

  // public getProjects() {
  //
  // }
}
