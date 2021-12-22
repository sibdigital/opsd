import {Component, Inject, OnInit, ViewChild} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";
import {merge, of as observableOf} from "rxjs";
import {MatSort} from "@angular/material/sort";
import {MatPaginator} from "@angular/material/paginator";
import {catchError, map, startWith, switchMap} from "rxjs/operators";
import {MatRow} from "@angular/material/table";
import {WorkPackage} from "core-components/work-packages/work-package.model";
import {Project} from "core-components/projects/project.model";
import {WorkPackageService} from "core-components/work-packages/work-package.service";
import {environment} from "../../../../environments/environment";
import {HttpClient, HttpParams} from "@angular/common/http";
import {WpService} from "core-components/work-packages/shared/wp.service";

@Component({
  selector: 'op-work-package-modal-selector-dialog',
  templateUrl: './work-package-modal-selector-dialog.component.html',
  styleUrls: ['./work-package-modal-selector-dialog.component.sass']
})
export class WorkPackageModalSelectorDialogComponent implements OnInit {

  displayedColumns:string[] = ['id', 'subject'];
  workPackages:WorkPackage[] = [];
  project:Project | undefined;
  keyWord:string = '';
  isLoadingResults = true;
  isRateLimitReached = false;
  @ViewChild(MatPaginator)  paginator!:MatPaginator;
  @ViewChild(MatSort) sort:MatSort = new MatSort;

  constructor(
    public dialogRef:MatDialogRef<WorkPackageModalSelectorDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data:any,
    private wpService:WpService,
    private http:HttpClient
  ) {
    this.project = this.data.project;
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
            return this.wpService.getAllByProjectIdAndNameAndPageAndSizeAndSort(
              (this.project) ? this.project.id : null, this.keyWord, this.paginator.pageIndex, this.paginator.pageSize, this.sort.active, this.sort.direction)
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
          return data._embedded.workPackages;
        })
      ).subscribe(data => {
      this.workPackages = data;
    });

  }

  keyWordChange(event:Event) {
    this.keyWord = (event.target as HTMLInputElement).value;
    this.paginator.pageIndex = 0;
    this.ngAfterViewInit();
  }

  selectWorkPackage(row:MatRow) {
    this.dialogRef.close({data: row});
  }

  getAllByProjectIdAndNameAndPageAndSizeAndSort(projectId:number, name:string, page:number, size:number, sort:string, sortDir:string) {
    sortDir = (sortDir === '') ? 'asc' : sortDir;
    let params = new HttpParams().set('projectId', projectId.toString()).set('subject', name)
                                 .set('page', page.toString()).set('size', size.toString())
                                 .set('sort',  sort.concat(',', sortDir)).set('projection', 'shortProjection');
    return this.http.get<any>(environment.jopsd_url + 'api/workPackages/search/findByProject_IdAndSubjectContainingIgnoreCase', {params: params});
  }
  closeDialog() {
    this.dialogRef.close();
  }
}
