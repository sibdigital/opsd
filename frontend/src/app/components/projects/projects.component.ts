import {Component, Injector, OnInit} from "@angular/core";
import {States} from "core-components/states.service";
import {StateService} from "@uirouter/core";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {PaginationService} from "core-components/table-pagination/pagination-service";

export const projectsSelector = 'projects';

const TestProjects: ProjectState[] = [
  {
    name: '«Обеспечение качественно нового уровня развития инфраструктуры культуры» «Культурная среда» в Бурятии',
    national_project: { name: 'Культура' } as NationalProject,
    federal_project: { name: 'Культурная среда' } as FederalProject,
    projectStatus: 'не начат',
    projectApproveStatus: 'инициирован',
    doneRatio: '7.00',
    requiredDiskSpace: '250 кБ',
    startDate: new Date(2019, 0, 1),
    dueDate: new Date(2024, 11, 31),
    items: [],
  },
  {
    name: 'Переселение жителей микрорайонов «УМТС - Икибзяк» и «Механизированная колонна – 136» поселка Таксимо, Муйского района.',
    national_project: {  } as NationalProject,
    federal_project: {  } as FederalProject,
    projectStatus: 'не начат',
    projectApproveStatus: 'инициирован',
    doneRatio: '0.00',
    requiredDiskSpace: '',
    startDate: new Date(2019, 0, 1),
    dueDate: new Date(2024, 11, 31),
    items: [],
  },
  {
    name: 'Формирование комфортной городской среды.',
    national_project: { name: 'Жильё и городская среда' } as NationalProject,
    federal_project: { name: 'Жилье' } as FederalProject,
    projectStatus: 'не начат',
    projectApproveStatus: 'инициирован',
    doneRatio: '50.00',
    requiredDiskSpace: '',
    startDate: new Date(2019, 0, 1),
    dueDate: new Date(2024, 11, 31),
    items: [],
  }
];

@Component({
  selector: projectsSelector,
  templateUrl: './projects.html',
  styleUrls: ['./projects.sass'],
})
export class ProjectsComponent implements OnInit {

  public projects: ProjectState[];
  public requiredDiskPlace = '3 проекта используют 250 кБ дискового пространства';
  public page:number;
  public count:number;
  public total:number;

  constructor(
    public injector:Injector,
    public states:States,
    readonly $state:StateService,
    protected halResourceService:HalResourceService,
    protected pathHelper:PathHelperService,
    public paginator: PaginationService,
  ) { }

  ngOnInit():void {
    console.dir({ States: this.states, StateService: this.$state });
    this.page = 1;
    this.count = 3;
    this.total = 3;

    this.projects = TestProjects.map((project) => {
      project.startDateCostil = [project.startDate.getDate(), project.startDate.getMonth() + 1, project.startDate.getFullYear()].join('.');
      project.endDateCostil = [project.dueDate.getDate(), project.dueDate.getMonth() + 1, project.dueDate.getFullYear()].join('.');
      return project;
    });

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

  // public getProjects() {
  //
  // }
}
