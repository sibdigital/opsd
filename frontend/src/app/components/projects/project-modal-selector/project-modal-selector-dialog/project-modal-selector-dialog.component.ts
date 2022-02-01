import {Component, Inject, OnInit, ViewChild} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";
import {Project} from "../../project.model";
import {merge, of as observableOf} from "rxjs";
import {MatSort} from "@angular/material/sort";
import {MatPaginator} from "@angular/material/paginator";
import {catchError, map, startWith, switchMap} from "rxjs/operators";
import {MatRow} from "@angular/material/table";
import {ProjectService} from "core-components/projects/shared/project.service";

@Component({
  selector: 'op-project-modal-selector-dialog',
  templateUrl: './project-modal-selector-dialog.component.html',
  styleUrls: ['./project-modal-selector-dialog.component.sass']
})
export class ProjectModalSelectorDialogComponent implements OnInit {

  displayedColumns:string[] = ['id', 'name'];
  projects:Project[] = [];
  keyWord:string = '';
  isLoadingResults = true;
  isRateLimitReached = false;
  @ViewChild(MatPaginator)  paginator!:MatPaginator;
  @ViewChild(MatSort) sort:MatSort = new MatSort;

  constructor(
    public dialogRef:MatDialogRef<ProjectModalSelectorDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public dialog_data:any,
    private projectService:ProjectService
  ) { }

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
          return this.projectService.getAllByNameAndPageAndSizeAndSort(
            this.keyWord, this.paginator.pageIndex, this.paginator.pageSize, this.sort.active, this.sort.direction)
            .pipe(catchError(() => observableOf(null)));
        }),
        map((data:any) => {
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
          return data._embedded.projects;
        })
      ).subscribe(data => {
        this.projects = data;
    });

  }

  keyWordChange(event:Event) {
    this.keyWord = (event.target as HTMLInputElement).value;
    this.paginator.pageIndex = 0;
    this.ngAfterViewInit();
  }

  selectProject(row:MatRow) {
    this.dialogRef.close({data: row});
  }
  closeDialog() {
    this.dialogRef.close();
  }

}
