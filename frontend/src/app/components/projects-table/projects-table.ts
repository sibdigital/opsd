import { Component, OnInit, ViewEncapsulation} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {DatePipe} from "@angular/common";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {
  DefaultProjectsColumnsTable, IFederalProject,
  INationalProject,
  IProjectsState,
  IProjectsTableColumn
} from "../projects/state/projects.state";
import {ProjectsTablePaginationService} from "core-components/projects-table/projects-table-pagination.service";


@Component({
  templateUrl: './projects-table.html',
  styleUrls: ['./projects-table.sass'],
  encapsulation: ViewEncapsulation.None,
  selector: 'projects-table',
  providers: [ProjectsTablePaginationService]
})
export class ProjectsTable implements OnInit {

  public columns: IProjectsTableColumn[];
  public projects: IProjectsState[];
  public locale: string;

  public totalPages: number = 1;
  public perPageSize: number = 25;
  public currentPage: number = 1;

  public isAllExpanded: boolean = false;
  // public expandText = {
  //   id: 'expandAll',
  //   name: 'РАЗВЕРНУТЬ ВСЕ',
  // };
  // public collapseText: string = 'СВЕРНУТЬ ВСЕ';

  public items: {}[] = [];

  public readonly DefaultProjectRegisteryProjection = Object.freeze({
    projection: 'projectRegisteryProjection'
  });

  constructor(
    readonly I18n: I18nService,
    public datepipe: DatePipe,
    protected halResourceService: HalResourceService,
    protected pathHelper: PathHelperService,
    public paginationService: ProjectsTablePaginationService,
  ) {
  }

  ngOnInit(): void {
    console.dir({ def: DefaultProjectsColumnsTable });
    this.columns = DefaultProjectsColumnsTable;
    this.locale = this.I18n.locale;
    this.loadProjects();
  }

  public getItems(identifier: string): {}[] {
    return [
      {
        //label_subproject_new
        linkText: 'Новый подпроект',
        icon: 'icon-add',
        href: `/projects/new?parent_id=${ identifier }`,
        onClick: () => {
          return true;
        }
      },
      {
        linkText: 'Настройки проекта',
        icon: 'icon-settings',
        href: `/projects/${ identifier }/settings`,
        onClick: () => {
          return true;
        }
      },
      {
        linkText: 'Архив',
        icon: 'icon-locked',
        href: `/projects/${ identifier }/archive`,
        onClick: () => {
          return true;
        }
      },
      {
        linkText: 'Копировать',
        icon: 'icon-copy',
        href: `/projects/${ identifier }/copy_project_from_admin`,
        onClick: () => {
          return true;
        }
      },
      {
        linkText: 'Удалить',
        icon: 'icon-delete',
        href: `/projects/${ identifier }/destroy_info`,
        onClick: () => {
          return true;
        }
      }
    ];
  }

  public onChangePage(pageNumber: number) {
    console.dir({ projectsTable: pageNumber });
    this.currentPage = pageNumber;
    this.paginationService.setCurrentPageParams({ page: pageNumber });
    this.loadProjects();
  }
  // id: string, sortDir: string = 'asc'
  public onSort(params: { id: string, sortDir: string }) {
    console.dir({ idSort: params.id, sortDir: params.sortDir });
    this.paginationService.setSortParams({ sort: [params.id, params.sortDir].join(',') });
    this.loadProjects();
  }

  public onChangePerPage(perPageSize: number) {
    console.dir({ perPageSize: perPageSize });
    this.paginationService.setPerPageSizeParams({ size: perPageSize, page: 0 });
    this.loadProjects();
  }

  private changeProjectViewField(projectIdentifier: string, field: 'isExpand' | 'isOpenMenu') {
    const index = this.projects.findIndex((project) => project.identifier === projectIdentifier);
    console.dir({ index, id: projectIdentifier });
    if (index >= 0 && this.projects && this.projects[index]) {
      console.dir({ project: this.projects[index][field], field });
      this.projects[index][field] = !this.projects[index][field];
    }
  }

  public onProjectExpand(projectIdentifier: string) {
    this.changeProjectViewField(projectIdentifier, 'isExpand');
  }

  public onOpenMenu(projectIdentifier: string) {
    this.changeProjectViewField(projectIdentifier, 'isOpenMenu');
  }

  public getIsOpenMenuStyle(isOpenMenu: boolean) {
    console.log('getIsOpenMenuStyle');
    return isOpenMenu ? { display: 'block' } : { display: 'none' };
  }

  public onAllProjectExpand() {
    this.isAllExpanded = !this.isAllExpanded;
    this.projects = this.projects.map((project) => {
      if (project.description) {
        project.isExpand = this.isAllExpanded;
      }
      return project;
    });
    console.dir({ bool: this.isAllExpanded, projects: this.projects });
  }

  public loadProjects(params: any = {}): void {
    if (!params) {
      params = { size: this.paginationService.perPageSize };
    } else {
      params = { ...params, ...this.paginationService.params };
    }

    this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.javaApiPath.projects.toString(),
      { projection: this.DefaultProjectRegisteryProjection.projection,...params }
      )
      .toPromise()
      .then((projects: CollectionResource<HalResource>) => {
        this.projects = this.parseProjectsFromJOPSD(projects);
      })
      .catch((reason) => console.log(reason));
  }

  private parseProjectsFromJOPSD(projects: CollectionResource<HalResource>) {
    console.dir({ response: projects });
    let result: IProjectsState[] = [];
    if (projects.source && projects.page && projects.page.size && projects.page.size > 0) {
      this.paginationService.page = projects.source.page;
      this.totalPages = projects.source.page.totalElements;
      projects.source._embedded.projects.forEach((project: any) => {
        const startDate = project.startDate ? new Date(project.startDate) : null;
        const dueDate = project.dueDate ? new Date(project.dueDate) : null;

        // <%= content_tag(:td,  (!project.national_project.nil? ? project.national_project.name : "") + (!project.federal_project.nil? ? (">" + project.federal_project.name) : "")) %>

        result.push({
          public: project.public,
          name: project.name,
          national_project: project.nationalProject,
          federal_project: project.federalProject,
          nationalProject: project.nationalProject && project.federalProject ? project.nationalProject.name + '>' + project.federalProject.name : '',
          projectStatus: project.projectStatus ? project.projectStatus.name || '' : '',
          projectApproveStatus: project.projectApproveStatus ? project.projectApproveStatus.name || '' : '',
          doneRatio: (Math.round(project.doneRatio * 100) / 100).toFixed(2),
          requiredDiskSpace: '',
          startDate: startDate,
          startDateView: startDate ? this.datepipe.transform(startDate, 'dd.MM.yyyy') : '',
          dueDate: dueDate,
          dueDateView: dueDate ? this.datepipe.transform(dueDate, 'dd.MM.yyyy') : '',
          identifier: project.identifier,
          description: project.description,
          isExpand: false,
          isOpenMenu: false,
        } as IProjectsState);
      });

      this.projects = result;
    }
    return result;
  }
}
