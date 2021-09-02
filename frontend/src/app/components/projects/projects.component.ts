import {Component, OnInit} from "@angular/core";
import {WorkPackageFiltersService} from "core-components/filters/wp-filters/wp-filters.service";


export const projectsSelector = 'projects';

@Component({
  selector: projectsSelector,
  templateUrl: './projects.component.html',
  styleUrls: ['./projects.component.sass'],
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

  }
}
