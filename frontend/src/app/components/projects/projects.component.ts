import {Component, OnInit} from "@angular/core";
import {WorkPackageFiltersService} from "core-components/filters/wp-filters/wp-filters.service";


export const projectsSelector = 'projects';

@Component({
  selector: projectsSelector,
  templateUrl: './projects.component.html',
  styleUrls: ['./projects.component.sass'],
})
export class ProjectsComponent implements OnInit {

  constructor(
    // public projectsVisibleService: WorkPackageFiltersService
  ) { }

  ngOnInit():void {

  }
}
