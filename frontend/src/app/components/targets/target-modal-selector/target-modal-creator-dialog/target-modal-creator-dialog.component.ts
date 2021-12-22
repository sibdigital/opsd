import {Component, Inject, OnInit, ViewChild} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";
import {HttpClient} from "@angular/common/http";
import {Target} from "../../target.model";
import {MatSnackBar, MatSnackBarConfig} from "@angular/material/snack-bar";
import {formatDate} from "@angular/common";
import {Project} from "core-components/projects/project.model";
import {Enumeration} from "core-components/enumerations/enumeration.model";
import {EnumerationSelectComponent} from "core-components/enumerations/enumeration-select/enumeration-select.component";
import {EnumerationService} from "core-components/enumerations/shared/enumeration.service";
import {environment} from "../../../../../environments/environment";

@Component({
  selector: 'op-target-modal-creator-dialog',
  templateUrl: './target-modal-creator-dialog.component.html',
  styleUrls: ['./target-modal-creator-dialog.component.sass']
})
export class TargetModalCreatorDialogComponent implements OnInit {
  project:Project | null;
  targetType:Enumeration | undefined;
  targetName:string = '';
  targetTypeList:Enumeration[] = [];

  @ViewChild('enumerationSelectComponent') enumerationSelectComponent:EnumerationSelectComponent;

  constructor(
    public dialogRef:MatDialogRef<TargetModalCreatorDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data:any,
    private enumerationService:EnumerationService,
    private httpClient:HttpClient,
    private _snackBar:MatSnackBar,
  ) {
    this.project = this.data.project;
  }

  ngOnInit():void {
    this.dialogRef.updateSize('50%');
    this.enumerationService.getAllByActiveAndTypeAndNameIn(true, 'TargetType', ['Цель', 'Показатель', 'Результат']).subscribe(
      (data) => {
        this.targetTypeList = data._embedded.enumerations;
      }
    );
  }

  setName(event:any) {
    this.targetName = event.target.value;
  }

  createTarget():void {

    let newTarget:Target = new Target();
    newTarget.id = null;
    if (this.enumerationSelectComponent.selectedEnumeration) {
      newTarget.targetType = environment.jopsd_url + '/api/enumerations/' + this.enumerationSelectComponent.selectedEnumeration.id;
    }
    newTarget.name = this.targetName;
    newTarget.parentId = 0;
    if (this.project) {
      newTarget.project = environment.jopsd_url + '/api/projects/' + this.project.id;
    }
    newTarget.createdAt = formatDate(Date.now(), 'yyyy-MM-ddThh:mm:ss.SSSZ', 'en-EN');
    newTarget.updatedAt = formatDate(Date.now(), 'yyyy-MM-ddThh:mm:ss.SSSZ', 'en-EN');


    this.httpClient.post<Target>(environment.jopsd_url + '/api/targets', newTarget).subscribe(
      (data) => {
          const config = new MatSnackBarConfig();
          config.panelClass = ['background-green'];
          config.verticalPosition = "top";
          config.horizontalPosition = 'right';
          config.duration = 2000;
          this._snackBar.open("Показатель сохранен", 'Ок', config);
          this.dialogRef.close();
      },
      error => {
        const config = new MatSnackBarConfig();
        config.panelClass = ['background-red'];
        config.verticalPosition = "top";
        config.horizontalPosition = 'right';
        config.duration = 2000;
        this._snackBar.open("Не удалось сохранить", 'Х', config);
      }
    );
  }

  getOutputType(outputSelectedType:Enumeration) {
    this.targetType = outputSelectedType;
  }

  closeDialog() {
    this.dialogRef.close();
  }
}
