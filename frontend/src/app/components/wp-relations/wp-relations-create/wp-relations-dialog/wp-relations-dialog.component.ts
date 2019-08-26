import {Component, Inject, OnInit, ViewChild} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef, MatPaginator, MatTableDataSource} from "@angular/material";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";

export interface PeriodicElement {
  id:string;
  subject:string;
  type:string|undefined;
  status:string;
  assignee:string;
}

@Component({
  selector: 'wp-relations-dialog',
  templateUrl: './wp-relations-dialog.html',
  styleUrls: ['./wp-relations-dialog.sass']
})
export class WpRelationsDialogComponent implements OnInit {
  displayedColumns:string[] = ['id', 'subject', 'type', 'status', 'assignee'];
  dataSource:MatTableDataSource<PeriodicElement>;
  planType:string|undefined;
  paginatorLength: number;
  paginatorIndex: number;
  paginatorSize: number;
  paginatorArray: any;
  public text = {
    subject: this.I18n.t('js.work_packages.properties.subject'),
    type: this.I18n.t('js.work_packages.properties.type'),
    status: this.I18n.t('js.work_packages.properties.status'),
    assignee: this.I18n.t('js.work_packages.properties.assignee'),
    planning: this.I18n.t('js.label_plan_stage_package').toLowerCase(),
    execution: this.I18n.t('js.label_work_package').toLowerCase()
  };

  constructor(
    public dialogRef:MatDialogRef<WpRelationsDialogComponent>,
    readonly I18n:I18nService,
    @Inject(MAT_DIALOG_DATA) public data:any) {
    this.dataSource = new MatTableDataSource<PeriodicElement>(data.wp_array);
    this.planType = data.planType;
    this.paginatorArray = data;
    this.paginatorLength = data.length;
    this.paginatorIndex = 0;
    this.paginatorSize = 5;
  }

  @ViewChild(MatPaginator) paginator:MatPaginator;

  ngOnInit() {
    this.dataSource.paginator = this.paginator;
    console.log(this.paginator);
  }

  onNoClick():void {
    this.dialogRef.close();
  }

  description():string {
    if (this.planType === 'execution') {
      return this.text.execution;
    }
    if (this.planType === 'planning') {
      return this.text.planning;
    }
    return "";
  }
}
