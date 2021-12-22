import {Component, Inject, OnInit, ViewChild} from '@angular/core';
import {MatPaginator} from "@angular/material/paginator";
import {MatSort} from "@angular/material/sort";
import {MAT_DIALOG_DATA, MatDialog, MatDialogConfig, MatDialogRef} from "@angular/material/dialog";
import {merge, of as observableOf} from "rxjs";
import {catchError, map, startWith, switchMap} from "rxjs/operators";
import {MatRow} from "@angular/material/table";
import {Project} from "core-components/projects/project.model";
import {Target} from "core-components/targets/target.model";
import {TargetService} from "core-components/targets/shared/target.service";
import {TargetModalCreatorDialogComponent} from "core-components/targets/target-modal-selector/target-modal-creator-dialog/target-modal-creator-dialog.component";

@Component({
  selector: 'op-target-modal-selector-dialog',
  templateUrl: './target-modal-selector-dialog.component.html',
  styleUrls: ['./target-modal-selector-dialog.component.sass']
})
export class TargetModalSelectorDialogComponent implements OnInit {

  displayedColumns:string[] = ['id', 'name'];
  targets:Target[] = [];
  project:Project | undefined;
  excludedTargets:Target[];
  keyWord:string = '';
  isLoadingResults = true;
  isRateLimitReached = false;
  @ViewChild(MatPaginator) paginator!:MatPaginator;
  @ViewChild(MatSort) sort:MatSort = new MatSort;

  constructor(
    public dialogRef:MatDialogRef<TargetModalSelectorDialogComponent>,
    public dialogAddForm:MatDialog,
    @Inject(MAT_DIALOG_DATA) public data:any,
    private targetService:TargetService
  ) {
    this.project = this.data.project;
    this.excludedTargets = this.data.excludedTargets;
  }

  ngOnInit():void {
    this.dialogRef.updateSize('80%');
  }

  ngAfterViewInit() {
    // If the user changes the sort order, reset back to the first page.
    this.sort.sortChange.subscribe(() => this.paginator.pageIndex = 0);

    merge(this.sort.sortChange, this.paginator.page)
      .pipe(
        startWith({}),
        switchMap(() => {
          this.isLoadingResults = true;
          let excludedIds = this.excludedTargets.map(ctr => ctr.id).toString();
          return this.targetService.getAllByProjectIdAndNameAndIdIsNotInAndPageAndSizeAndSort(
            (this.project) ? this.project.id : null, this.keyWord, excludedIds, this.paginator.pageIndex, this.paginator.pageSize, this.sort.active, this.sort.direction)
            .pipe(catchError(() => observableOf(null)));
        }),
        map(data => {
          // Flip flag to show that loading has finished.
          this.isLoadingResults = false;
          this.isRateLimitReached = data.page.number === data.page.totalPages;

          if (data === null) {
            return [];
          }

          // Only refresh the result length if there is new data. In case of rate
          // limit errors, we do not want to reset the paginator to zero, as that
          // would prevent users from re-triggering requests.
          // this.resultsLength = data.page.totalPages;
          this.paginator.length = data.page.totalElements;
          return data._embedded.targets;
        })
      ).subscribe(data => {
      this.targets = data;
      // var excludedTargetsIds = this.excludedTargets.map(ctr => ctr.id);
      // this.targets = this.targets.filter(target => !excludedTargetsIds.includes(target.id));
    });

  }

  keyWordChange(event:Event) {
    this.keyWord = (event.target as HTMLInputElement).value;
    this.paginator.pageIndex = 0;
    this.ngAfterViewInit();
  }

  selectTarget(row:MatRow) {
    this.dialogRef.close({data: row});
  }

  openAddForm() {
    let matDialogConfig:MatDialogConfig = {
      panelClass: "dialog-responsive",
      data: {
        project: this.project,
      },
      autoFocus: false
    };
    const dialogRef = this.dialogAddForm.open(TargetModalCreatorDialogComponent, matDialogConfig);

    dialogRef.afterClosed().subscribe(result => {
      this.paginator.pageIndex = 0;
      this.ngAfterViewInit();
    });
  }

  closeDialog() {
    this.dialogRef.close();
  }
}
