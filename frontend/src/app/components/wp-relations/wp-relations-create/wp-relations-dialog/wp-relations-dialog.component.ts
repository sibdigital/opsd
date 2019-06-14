import {Component, EventEmitter, Inject, Input, OnInit, Output, ViewChild} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialog, MatDialogRef, MatPaginator, MatTableDataSource} from "@angular/material";
import {WorkPackageResource} from "app/modules/hal/resources/work-package-resource";
import {CollectionResource} from "app/modules/hal/resources/collection-resource";

export interface PeriodicElement {
  id: number;
  subject: string;
}

@Component({
  selector: 'wp-relations-dialog',
  templateUrl: './wp-relations-dialog.component.html'
})
export class WpRelationsDialogComponent {
  @Input() readonly workPackage:WorkPackageResource;
  @Input() selectedRelationType:string;
  public selectedWpId:string;

  @Output('onWorkPackageIdSelected') public onSelect = new EventEmitter<string|null>();

  constructor(public dialog: MatDialog) {

  }

  openDialog(): void {
    let ELEMENT_DATA:PeriodicElement[] = [];
    this.autocompleteWorkPackages().then((values) => {
      values.map(wp => {
        //console.log(wp.source.id + " " + wp.source.subject);
        ELEMENT_DATA.push({id: wp.source.id, subject: wp.source.subject});
      })
      const dialogRef = this.dialog.open(WpRelationsDialogModalComponent, {
        width: '750px',
        data: ELEMENT_DATA
      });
      dialogRef.afterClosed().subscribe(result => {
        this.selectedWpId = result;
        this.onSelect.emit(result);
      });
    });
  }

  private autocompleteWorkPackages():Promise<WorkPackageResource[]> {
    return this.workPackage.availableRelationCandidates.$link.$fetch({
      query: '',
      type: this.selectedRelationType,
      pageSize: 1024,//as unlimited
    }).then((collection:CollectionResource) => {
      return collection.elements || [];
    }).catch(() => {
      return [];
    });
  }
}

@Component({
  selector: 'wp-relations-dialog-modal',
  templateUrl: './wp-relations-dialog-modal.html',
  styles:  ['table {width: 100%}'],
})
export class WpRelationsDialogModalComponent implements OnInit{
  displayedColumns: string[] = ['id', 'subject'];
  dataSource: MatTableDataSource<PeriodicElement>;

  constructor(
    public dialogRef: MatDialogRef<WpRelationsDialogModalComponent>,
    @Inject(MAT_DIALOG_DATA) public ELEMENT_DATA: PeriodicElement[]) {

    this.dataSource = new MatTableDataSource<PeriodicElement>(ELEMENT_DATA);
  }

  @ViewChild(MatPaginator) paginator: MatPaginator;

  ngOnInit() {
    this.dataSource.paginator = this.paginator;
  }

  onNoClick(): void {
    this.dialogRef.close();
  }
}
