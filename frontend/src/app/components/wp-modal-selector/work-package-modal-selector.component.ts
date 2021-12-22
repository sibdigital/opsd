import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {MatDialog, MatDialogConfig} from "@angular/material/dialog";
import {WorkPackageModalSelectorDialogComponent} from "./work-package-modal-selector-dialog/work-package-modal-selector-dialog.component";
import {Project} from "core-components/projects/project.model";
import {WorkPackage} from "core-components/work-packages/work-package.model";

@Component({
  selector: 'op-work-package-modal-selector',
  templateUrl: './work-package-modal-selector.component.html',
  styleUrls: ['./work-package-modal-selector.component.sass']
})
export class WorkPackageModalSelectorComponent implements OnInit {

  @Input() selectedWorkPackage:WorkPackage | undefined;
  @Output() outputSelectedWorkPackage = new EventEmitter<any>();
  project:Project | undefined;
  disabled:boolean = false;

  constructor(public dialog:MatDialog) { }

  ngOnInit():void {
    //
  }

  chooseWorkPackage():void {
    let matDialogConfig:MatDialogConfig = {
      panelClass: "dialog-responsive",
      data: {
        project: this.project
      },
      autoFocus: false
    };
    const dialogRef = this.dialog.open(WorkPackageModalSelectorDialogComponent, matDialogConfig
      // {
      //   minWidth: 0.8 * window.innerWidth,
      //   maxWidth: 0.8 * window.innerWidth,
      //   data: {
      //     project: this.project
      //   }
      // }
    );

    dialogRef.afterClosed().subscribe(result => {
      if (result.data) {
        this.selectedWorkPackage = result.data;
        this.outputSelectedWorkPackage.emit(result.data);
      }
    });
  }

  openWorkPackage(event:any) {
    event.stopPropagation();
    if (this.selectedWorkPackage && this.project) {
      window.open(window.appBasePath + "/projects/" + this.project.identifier + "/work_packages/" + this.selectedWorkPackage.id, "_blank");
    }
  }

  setProjectAndResetWorkPackage(project:Project) {
    this.project = project;
    this.selectedWorkPackage = undefined;
  }

  setProject(project:Project) {
    this.project = project;
  }

  setWorkPackage(workPackage:WorkPackage) {
    this.selectedWorkPackage = workPackage;
  }

  disableChoice() {
    this.disabled = true;
  }

  enableChoice() {
    this.disabled = false;
  }

}
