import {Component, OnInit} from "@angular/core";
import {ProjectsTableFiltersService} from "core-components/projects-table/projects-table-filters.service";


export const projectsSelector = 'projects';

@Component({
  selector: projectsSelector,
  templateUrl: './projects.component.html',
  styleUrls: ['./projects.component.sass'],
  providers: [ProjectsTableFiltersService]
})
export class ProjectsComponent implements OnInit {

  isExpandFilter = false;

  constructor(
  ) { }

  ngOnInit():void {
  }

  toggleFilter(isClose = !this.isExpandFilter) {
    this.isExpandFilter = isClose;
  }
}
