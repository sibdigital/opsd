import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {MatDialog, MatDialogConfig} from "@angular/material/dialog";
import {Project} from "core-components/projects/project.model";
import {ProjectModalSelectorDialogComponent} from "core-components/projects/project-modal-selector/project-modal-selector-dialog/project-modal-selector-dialog.component";

@Component({
  selector: 'op-project-modal-selector',
  templateUrl: './project-modal-selector.component.html',
  styleUrls: ['./project-modal-selector.component.sass']
})
export class ProjectModalSelectorComponent implements OnInit {

  @Input() selectedProject:Project | undefined;
  @Output() outputSelectedProject = new EventEmitter<any>();
  disabled:boolean = false;


  constructor(public dialog:MatDialog) {
  }

  ngOnInit():void {
    //
  }


  chooseProject():void {
    let matDialogConfig:MatDialogConfig = {
      panelClass: "dialog-responsive",
      autoFocus: false
    };
    const dialogRef = this.dialog.open(ProjectModalSelectorDialogComponent, matDialogConfig);

    dialogRef.afterClosed().subscribe(result => {
      if (result.data) {
        this.selectedProject = result.data;
        this.outputSelectedProject.emit(result.data);
      }
    });
  }

  openProject(event:any) {
    event.stopPropagation();
    if (this.selectedProject) {
      window.open(window.appBasePath + "/projects/" + this.selectedProject.identifier, "_blank");
    }
  }

  setProject(project:any) {
    if (project) {
      this.selectedProject = project;
    }
  }

  disableChoice() {
    this.disabled = true;
  }

  enableChoice() {
    this.disabled = false;
  }
}
