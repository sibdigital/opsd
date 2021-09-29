import {EventEmitter, Injectable, Output} from "@angular/core";
import {
  ProjectsTableFilters,
  ProjectsTableSelectedFilter
} from "core-components/projects/projects-filters/projects-filters-state.component";


@Injectable()
export class ProjectsTableFiltersService {

  @Output() public onFiltersApply = new EventEmitter<ProjectsTableFilters>();

  private filters: ProjectsTableFilters;
  private selectedFilters: ProjectsTableSelectedFilter[];

  constructor(
  ) {
  }

  applyFilters(filters: ProjectsTableFilters) {
    this.filters = filters;
    this.onFiltersApply.emit(filters);
  }

  setSelectedFilters(selectedFilters: ProjectsTableSelectedFilter[]) {
    this.selectedFilters = selectedFilters;
  }

  getFilters() {
    return this.filters;
  }

  getSelectedFilters() {
    return this.selectedFilters;
  }
}
