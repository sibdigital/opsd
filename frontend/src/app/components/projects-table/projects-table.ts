import {Component, OnInit, ViewEncapsulation} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {DefaultProjectsColumnsTable, IProjectsState, IProjectsTableColumn} from "../projects/state/projects.state";
import {ProjectsTablePaginationService} from "core-components/projects-table/projects-table-pagination.service";
import {LoadingIndicatorService} from "core-app/modules/common/loading-indicator/loading-indicator.service";
import {ProjectsTableFiltersService} from "core-components/projects-table/projects-table-filters.service";
import {HttpClient, HttpParams} from "@angular/common/http";
import {NotificationsService} from "core-app/modules/common/notifications/notifications.service";
import {ProjectsTableFilters} from "core-components/projects/projects-filters/projects-filters-state.component";


@Component({
  templateUrl: './projects-table.html',
  styleUrls: ['./projects-table.sass'],
  encapsulation: ViewEncapsulation.None,
  selector: 'projects-table',
  providers: [ProjectsTablePaginationService]
})
export class ProjectsTable implements OnInit {

  public columns:IProjectsTableColumn[];
  public projects:IProjectsState[];
  public locale:string;

  public isAllExpanded:boolean = false;

  public readonly DefaultProjectRegisteryProjection = Object.freeze({
    projection: 'projectRegisteryProjection'
  });

  constructor(
    readonly I18n:I18nService,
    protected pathHelper:PathHelperService,
    public paginationService:ProjectsTablePaginationService,
    private loadingIndicatorService:LoadingIndicatorService,
    private projectsTableFiltersService:ProjectsTableFiltersService,
    private httpClient:HttpClient,
    private notificationService:NotificationsService
  ) {
  }

  ngOnInit():void {
    console.dir({def: DefaultProjectsColumnsTable});
    this.columns = DefaultProjectsColumnsTable;
    this.locale = this.I18n.locale;
    this.loadProjects();
    this.checkFilters();
  }

  checkFilters() {
    this.projectsTableFiltersService.onFiltersApply.subscribe(() => {
      this.paginationService.setCurrentPageParams({page: 0});
      this.loadProjects();
    });
  }

  public getItems(project:IProjectsState):{}[] {
    var addSubprojectButton = {
      //label_subproject_new
      linkText: 'Новый подпроект',
      icon: 'icon-add',
      href: `/projects/new?parent_id=${project.identifier}`
    };
    var archiveButton = {
      linkText: 'Архив',
      icon: 'icon-locked',
      // href: `/projects/${ identifier }/archive`,
      onClick: () => {
        this.httpClient.get(this.pathHelper.javaUrlPath + `/projects/${project.id}/archive` )
          .toPromise()
          .then((value) => {

            this.loadProjects();
            this.notificationService.addSuccess('Проект успешно заархивирован');  //как добавить timeout на уведомление?
            setTimeout(() => this.notificationService.remove(this.notificationService.addSuccess("")), 3600);
          });
        return true;
      }
    };
    var unarchiveButton = {
      linkText: 'Разархивировать',
        icon: 'icon-unlocked',
        // href: `/projects/${ identifier }/unarchive`,
        onClick: () => {
        this.httpClient.get(this.pathHelper.javaUrlPath + `/projects/${project.id}/unarchive` )
          .toPromise()
          .then((value) => {
            if (value) {
              this.loadProjects();
              this.notificationService.addSuccess('Проект успешно разархивирован');
              setTimeout(() => this.notificationService.remove(this.notificationService.addSuccess("")), 3600);
            } else {
              this.notificationService.addError('Подпроект не может быть разархивирован, проверьте статус родительского проекта');
              setTimeout(() => this.notificationService.remove(this.notificationService.addError("")), 7700);
            }

          });
        return true;
      }
    };
    var settingsButton =       {
      linkText: 'Настройки проекта',
      icon: 'icon-settings',
      href: `/projects/${project.identifier}/settings`
    };
    var copyButton =       {
      linkText: 'Копировать',
      icon: 'icon-copy',
      href: `/projects/${project.identifier}/copy_project_from_admin`
    };
    var deletButton =       {
      linkText: 'Удалить',
      icon: 'icon-delete',
      href: `/projects/${project.identifier}/destroy_info`//,
      // onClick: () => {
      //   return true;
      // }
    };
    if (project.status !== 9) {
      return [
        addSubprojectButton,
        archiveButton,
        settingsButton,
        copyButton,
        deletButton
      ];
    } else {
      return [
        unarchiveButton,
        copyButton,
        deletButton
      ];
    }

  }

  public onChangePage(pageNumber:number) {
    console.dir({projectsTable: pageNumber});
    this.paginationService.currentPage = pageNumber;
    this.loadProjects();
  }

  public onSort(params:{ id:string, sortDir:string }) {
    console.dir({idSort: params.id, sortDir: params.sortDir});
    this.paginationService.setSortParams({sort: [params.id, params.sortDir].join(',')});
    this.loadProjects();
  }

  public onChangePerPage(perPageSize:number) {
    console.dir({perPageSize: perPageSize});
    this.paginationService.setPerPageSizeParams({size: perPageSize, page: 0});
    this.loadProjects();
  }

  private changeProjectViewField(projectIdentifier:string, field:'isExpand' | 'isOpenMenu') {
    const index = this.projects.findIndex((project) => project.identifier === projectIdentifier);
    // console.dir({ index, id: projectIdentifier });
    if (index >= 0 && this.projects && this.projects[index]) {
      // console.dir({ project: this.projects[index][field], field });
      this.projects[index][field] = !this.projects[index][field];
    }
  }

  public onProjectExpand(projectIdentifier:string) {
    this.changeProjectViewField(projectIdentifier, 'isExpand');
  }

  public onOpenMenu(projectIdentifier:string) {
    this.changeProjectViewField(projectIdentifier, 'isOpenMenu');
  }

  public getIsOpenMenuStyle(isOpenMenu:boolean) {
    console.log('getIsOpenMenuStyle');
    return isOpenMenu ? {display: 'block'} : {display: 'none'};
  }

  public onAllProjectExpand() {
    this.isAllExpanded = !this.isAllExpanded;
    this.projects = this.projects.map((project) => {
      if (project.description) {
        project.isExpand = this.isAllExpanded;
      }
      return project;
    });
    console.dir({bool: this.isAllExpanded, projects: this.projects});
  }

  public loadProjects(params:any = {}):void {
    const baseUrl = this.pathHelper.javaApiPath.projects.toString();

    try {
      let params = new HttpParams()
        .set('size', this.paginationService.perPageSize ? this.paginationService.perPageSize.toString() : '25')
        .set('page', this.paginationService.currentPage ? this.paginationService.currentPage.toString() : '0');
      const filters:any = this.projectsTableFiltersService.getFilters();

      if (filters) {
        Object.keys(filters).forEach(key => {
          params = params.set(key, filters[key]);
        });
      }
      this.loadingIndicatorService.indicator('projects-table').promise =
        this.httpClient.get(
          `${baseUrl}${this.projectsTableFiltersService.getFilters() ? '/search/findByProjectRegisterFields' : ''}`,
          {params
          }
        )
          .toPromise()
          .then((projects:any) => {
            this.projects = projects._embedded.projects;
            this.paginationService.page = projects.page;
          })
          .catch((reason) => console.log(reason));
    } catch (e) {
      console.log(e);
    }
  }
}
