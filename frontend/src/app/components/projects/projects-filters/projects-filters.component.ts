import {AfterViewInit, Component, EventEmitter, OnDestroy, Output} from '@angular/core';
import {WorkPackageTableFilters} from 'core-components/wp-fast-table/wp-table-filters';
import {componentDestroyed} from 'ng2-rx-componentdestroyed';
import {DebouncedEventEmitter} from "core-components/angular/debounced-event-emitter";
import {FormControl, FormGroup} from "@angular/forms";
import {ProjectsTableFiltersService} from "core-components/projects-table/projects-table-filters.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {
  ProjectsTableFilters,
  ProjectsTableSelectedFilter
} from "core-components/projects/projects-filters/projects-filters-state.component";

@Component({
  templateUrl: './projects-filters.component.html',
  styleUrls: ['./projects-filters.component.sass'],
  selector: 'projects-filters',
})
export class ProjectsFiltersComponent implements AfterViewInit, OnDestroy {

  @Output() public filtersChanged = new DebouncedEventEmitter<WorkPackageTableFilters>(componentDestroyed(this));
  @Output() public onFilterClose = new EventEmitter<boolean>();

  filtersFormGroup = new FormGroup({
    startDateFormGroup: new FormGroup({
      selected: new FormControl(false),
      selectedFilter: new FormControl(''),
      leftValue: new FormControl(''),
      rightValue: new FormControl(''),
    }),
    dueDateFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      leftValue: new FormControl(''),
      rightValue: new FormControl(''),
    }),
    identifierFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      value: new FormControl(''),
    }),
    nameFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      value: new FormControl(''),
    }),
    nationalProjectFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      value: new FormControl(''),
    }),
    lastActivityFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      leftValue: new FormControl(''),
      rightValue: new FormControl(''),
    }),
    doneRatioFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      value: new FormControl(''),
    }),
    createdOnFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      leftValue: new FormControl(''),
      rightValue: new FormControl(''),
    }),
    statusFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      value: new FormControl(''),
    }),
    federalProjectFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      value: new FormControl(''),
    }),
    projectApproveStatusFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      value: new FormControl(''),
    }),
    projectStatusFormGroup: new FormGroup({
      selectedFilter: new FormControl(''),
      value: new FormControl(''),
    }),
  });

  currentFiltersFormControl = new FormControl();

  selectedFilters: ProjectsTableSelectedFilter[] = [
    {
      selected: false,
      value: '',
      title: 'Пожалуйста, выберите',
    },
    {
      selected: false,
      value: 'startDate',
      title: 'Дата начала',
    },
    {
      selected: false,
      value: 'dueDate',
      title: 'Дата окончания',
    },
    {
      selected: false,
      value: 'identifier',
      title: 'Идентификатор',
    },
    {
      selected: false,
      value: 'name',
      title: 'Наименование',
    },
    {
      selected: false,
      value: 'nationalProject',
      title: 'Национальный проект',
    },
    {
      selected: false,
      value: 'lastActivity',
      title: 'Последняя активность',
    },
    // {
    //   selected: false,
    //   value: 'doneRatio',
    //   title: 'Процент исполнения',
    // },
    {
      selected: false,
      value: 'createdDate',
      title: 'Создано',
    },
    {
      selected: false,
      value: 'projectStatus',
      title: 'Статус',
    },
    {
      selected: false,
      value: 'federalProject',
      title: 'Федеральный проект',
    },
    {
      selected: false,
      value: 'projectApproveStatus',
      title: 'Этап согласования',
    },
    {
      selected: false,
      value: 'status',
      title: 'Активно или в архиве',
    },
  ];

  federalProjects: object[] = [];
  nationalProjects: object[] = [];
  projectApproveStatuses: object[] = [];
  projectStatuses: object[] = [];

  constructor(
    private ProjectsTableFiltersService: ProjectsTableFiltersService,
    private halResourceService: HalResourceService,
    private pathHelper: PathHelperService,
  ) {
  }

  ngOnDestroy() {
  }

  ngAfterViewInit() {
    if (this.ProjectsTableFiltersService.getSelectedFilters()) {
      this.selectedFilters = this.ProjectsTableFiltersService.getSelectedFilters();
    }
    this.parseFederalProjects();
    this.parseNationalProjects();
    this.parseProjectApproveStatuses();
    this.parseProjectStatuses();
  }

  isSelectedFilter(value: string): boolean {
    for (let i = 0; i < this.selectedFilters.length; i++) {
      if (value === this.selectedFilters[i].value) {
        return this.selectedFilters[i].selected;
      }
    }
    return false;
  }

  parseNationalProjects() {
    this.loadNationalProjects('National');
  }

  parseFederalProjects() {
    this.loadNationalProjects('Federal');
  }

  parseProjectApproveStatuses() {
    this.loadStatuses('ProjectApproveStatus');
  }

  parseProjectStatuses() {
    this.loadStatuses('ProjectStatus');
  }

  loadStatuses(type: 'ProjectStatus' | 'ProjectApproveStatus') {
    this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.javaApiPath.enumerations.toString() + '/search/findByType', { type })
      .toPromise()
      .then((statuses: CollectionResource<HalResource>) => {
        const parseStatuses = () => {
          return statuses.source._embedded.enumerations.map((status: any) => {
            status.id = status._links.self.href.substring((status._links.self.href.lastIndexOf('/')) + 1);
            return status;
          });
        };
        if (type === 'ProjectStatus') {
          this.projectStatuses = parseStatuses();
        } else if (type === 'ProjectApproveStatus') {
          this.projectApproveStatuses = parseStatuses();
        }
      })
      .catch((reason) => console.error(reason));
  }

  loadNationalProjects(type: 'Federal' | 'National') {
    this.halResourceService.get<CollectionResource<HalResource>>(
      this.pathHelper.javaApiPath.nationalProjects.toString() + '/search/findByType', { type })
      .toPromise()
      .then((projects: CollectionResource<HalResource>) => {
        const parseProjects = () => {
          return projects.source._embedded.nationalProjects.map((project: any) => {
            project.id = project._links.self.href.substring((project._links.self.href.lastIndexOf('/')) + 1);
            return project;
          });
        };
        if (type === 'Federal') {
          this.federalProjects = parseProjects();
        } else if (type === 'National') {
          this.nationalProjects = parseProjects();
        }
      })
      .catch((reason) => console.error(reason));
  }

  _onFilterClose() {
    this.onFilterClose.emit(false);
  }

  onCloseFilter(value:string) {
    this.selectedFilters = this.selectedFilters.map((filter) => {
      if (value === filter.value) {
        filter.selected = false;
        this.filtersFormGroup.get(`${value}FormGroup`)!.value.value = null;
      }
      return filter;
    });
  }

  onSelectFilter() {
    this.selectedFilters = this.selectedFilters.map((filter) => {
      if (this.currentFiltersFormControl.value === filter.value) {
        filter.selected = true;
        this.currentFiltersFormControl.patchValue('');
      }
      return filter;
    });
  }

  // TODO: KOSTIL В RUBY DATEPICKER
  onRubyDatePickerGetValue() {
    // @ts-ignore
    const dateStartLeftValue = document.getElementById('start_date_left_value') === null ? '' : document.getElementById('start_date_left_value').value;
    // @ts-ignore
    const dateStartRightValue = document.getElementById('start_date_right_value') === null ? '' : document.getElementById('start_date_right_value').value;
    // @ts-ignore
    const dueDateLeft = document.getElementById('due_date_left_value') === null ? '' : document.getElementById('due_date_left_value').value;
    // @ts-ignore
    const dueDateRight = document.getElementById('due_date_right_value') === null ? '' : document.getElementById('due_date_right_value').value;
    // @ts-ignore
    const updatedOnLeft = document.getElementById('updated_on_date_left_value') === null ? '' : document.getElementById('updated_on_date_left_value').value;
    // @ts-ignore
    const updatedOnRight = document.getElementById('updated_on_date_right_value') === null ? '' : document.getElementById('updated_on_date_right_value').value;
    // @ts-ignore
    const createdOnLeft = document.getElementById('created_on_date_left_value') === null ? '' : document.getElementById('created_on_date_left_value').value;
    // @ts-ignore
    const createdOnRight = document.getElementById('created_on_date_right_value') === null ? '' : document.getElementById('created_on_date_right_value').value;
    // @ts-ignore
    this.filtersFormGroup.get('startDateFormGroup').patchValue({
      leftValue: dateStartLeftValue,
      rightValue: dateStartRightValue,
    });
    // @ts-ignore
    this.filtersFormGroup.get('dueDateFormGroup').patchValue({
      leftValue: dueDateLeft,
      rightValue: dueDateRight,
    });
    // @ts-ignore
    this.filtersFormGroup.get('lastActivityFormGroup').patchValue({
      leftValue: updatedOnLeft,
      rightValue: updatedOnRight,
    });
    // @ts-ignore
    this.filtersFormGroup.get('createdOnFormGroup').patchValue({
      leftValue: createdOnLeft,
      rightValue: createdOnRight,
    });
  }

  buildFilters(): ProjectsTableFilters {
    const identifierForm = this.filtersFormGroup.get('identifierFormGroup');
    const identVal = identifierForm && identifierForm.value.value !== '' ? identifierForm.value.value : null;

    const nameForm = this.filtersFormGroup.get('nameFormGroup');
    const nameVal = nameForm && nameForm.value.value !== '' ? nameForm.value.value : null;

    const nationalProjectFormGroup = this.filtersFormGroup.get('nationalProjectFormGroup');
    const natVal = nationalProjectFormGroup && nationalProjectFormGroup.value.value !== '' ? nationalProjectFormGroup.value.value : null;

    const statusFormGroup = this.filtersFormGroup.get('statusFormGroup');
    const statusVal = statusFormGroup && statusFormGroup.value.value !== '' ? statusFormGroup.value.value : null;

    const federalProjectFormGroup = this.filtersFormGroup.get('federalProjectFormGroup');
    const fedVal = federalProjectFormGroup && federalProjectFormGroup.value.value !== '' ? federalProjectFormGroup.value.value : null;

    const projectApproveStatusFormGroup = this.filtersFormGroup.get('projectApproveStatusFormGroup');
    const projectApproveStatusVal = projectApproveStatusFormGroup && projectApproveStatusFormGroup.value.value !== '' ? projectApproveStatusFormGroup.value.value : null;

    const projectStatusFormGroup = this.filtersFormGroup.get('projectStatusFormGroup');
    const projectStatusVal = projectStatusFormGroup && projectStatusFormGroup.value.value !== '' ? projectStatusFormGroup.value.value : null;

    const defaultDateLeftValue = '1900-01-01'; // TODO: KOSTIL B JOPSD findByProjectRegisterFields
    const defaultDateRightValue = '2990-01-01'; // TODO: KOSTIL B JOPSD findByProjectRegisterFields

    const startDateFormGroup = this.filtersFormGroup.get('startDateFormGroup');
    const startDateLeft = startDateFormGroup && startDateFormGroup.value.leftValue !== '' ? startDateFormGroup.value.leftValue : defaultDateLeftValue;
    const startDateRight = startDateFormGroup && startDateFormGroup.value.rightValue !== '' ? startDateFormGroup.value.rightValue : defaultDateRightValue;

    const dueDateFormGroup = this.filtersFormGroup.get('dueDateFormGroup');
    const dueDateLeft = dueDateFormGroup && dueDateFormGroup.value.leftValue !== '' ? dueDateFormGroup.value.leftValue : defaultDateLeftValue;
    const dueDateRight = dueDateFormGroup && dueDateFormGroup.value.rightValue !== '' ? dueDateFormGroup.value.rightValue : defaultDateRightValue;

    const lastActivityFormGroup = this.filtersFormGroup.get('lastActivityFormGroup');
    const updatedOnLeft = lastActivityFormGroup && lastActivityFormGroup.value.leftValue !== '' ? lastActivityFormGroup.value.leftValue : defaultDateLeftValue;
    const updatedOnRight = lastActivityFormGroup && lastActivityFormGroup.value.rightValue !== '' ? lastActivityFormGroup.value.rightValue : defaultDateRightValue;

    const createdOnFormGroup = this.filtersFormGroup.get('createdOnFormGroup');
    const createdOnLeft = createdOnFormGroup && createdOnFormGroup.value.leftValue !== '' ? createdOnFormGroup.value.leftValue : defaultDateLeftValue;
    const createdOnRight = createdOnFormGroup && createdOnFormGroup.value.rightValue !== '' ? createdOnFormGroup.value.rightValue : defaultDateRightValue;

    return {
      ...identVal && { identifier: identVal },
      ...natVal && { national_project_id: natVal },
      ...fedVal && { federal_project_id: fedVal },
      ...projectApproveStatusVal && { project_approve_status_id: projectApproveStatusVal },
      ...projectStatusVal && { project_status_id: projectStatusVal },
      ...statusVal && { status: statusVal },
      ...nameVal && { name: nameVal },
      ...startDateLeft && startDateRight && { start_date_left: startDateLeft, start_date_right: startDateRight },
      ...dueDateLeft && dueDateRight && { due_date_left: dueDateLeft, due_date_right: dueDateRight },
      ...updatedOnLeft && updatedOnRight && { updated_on_left: updatedOnLeft, updated_on_right: updatedOnRight },
      ...createdOnLeft && createdOnRight && { created_on_left: createdOnLeft, created_on_right: createdOnRight },
    };
  }

  onApplyFilters() {
    this.onRubyDatePickerGetValue();
    this.ProjectsTableFiltersService.applyFilters(this.buildFilters());
    this.ProjectsTableFiltersService.setSelectedFilters(this.selectedFilters);
  }
}
