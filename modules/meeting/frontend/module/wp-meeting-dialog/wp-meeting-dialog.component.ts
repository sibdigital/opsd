import {Component, Inject, OnInit, ElementRef, Optional, ViewChild} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef, MatPaginator, MatTableDataSource} from "@angular/material";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
// import { DragDropModule } from '@angular/cdk/drag-drop';


export interface PeriodicElement {
  id: string;
  subject: string;
  type: string|undefined;
  status: string;
  assignee: string;
}

@Component({
  selector: 'wp-meeting-dialog',
  templateUrl: './wp-meeting-dialog.html',
  styleUrls: ['./wp-meeting-dialog.sass']
})
export class WpMeetingDialogComponent implements OnInit{
  displayedColumns: string[] = ['id', 'subject', 'type', 'status', 'assignee'];
  dataSource: MatTableDataSource<PeriodicElement>;
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
  @ViewChild(MatPaginator) paginator: MatPaginator;
  constructor(
    public dialogRef: MatDialogRef<WpMeetingDialogComponent>,
    readonly I18n:I18nService,
    @Inject(MAT_DIALOG_DATA) public data: any) {
    this.paginatorArray = data;
    this.paginatorLength = data.length;
    this.dataSource = data;
    this.paginatorIndex = 0;
    this.paginatorSize = 20;
  }



  ngOnInit() {
    this.dataSource.paginator = this.paginator;
  }


  // loadPage() {
  //   this.dataSource=this.paginatorArray
  // }

  onNoClick(): void {
    this.dialogRef.close();
  }
}
