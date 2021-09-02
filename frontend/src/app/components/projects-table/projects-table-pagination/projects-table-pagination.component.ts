import {
  Component, EventEmitter, Input,
  OnDestroy,
  OnInit, Output,
  ViewEncapsulation
} from "@angular/core";
import {ProjectsTablePaginationService} from "core-components/projects-table/projects-table-pagination.service";


@Component({
  templateUrl: './projects-table-pagination.component.html',
  styleUrls: ['./projects-table-pagination.component.sass'],
  encapsulation: ViewEncapsulation.None,
  selector: 'projects-table-pagination',
})
export class ProjectsTablePaginationComponent implements OnInit, OnDestroy {

  @Input() paginationService: ProjectsTablePaginationService;

  @Output() onChangePage = new EventEmitter<any>();
  @Output() onChangePerPage = new EventEmitter<any>();

  constructor(
  ) {
  }

  ngOnInit(): void {
    console.dir({ paginationService: this.paginationService.page });
  }

  ngOnDestroy(): void {
  }

  setCurrent(e: any, pageNumber: number) {
    e.preventDefault();
    this.onChangePage.emit(pageNumber);
  }

  public get offsetStart(): number {
    const currentPage = this.paginationService.currentPage;
    const perPage = this.paginationService.perPageSize;
    return (currentPage * perPage) + 1;
  }

  public get offsetEnd(): number {
    const currentPage = this.paginationService.currentPage;
    const perPage = this.paginationService.perPageSize;
    return Math.min(((currentPage * perPage) + 1) + perPage - 1, this.paginationService.totalElements);
  }

  public get perPagesSize(): number[] {
    return this.paginationService.perPagesSizes;
  }

  public setPerPageSize(perPageSize: number) {
    this.paginationService.perPageSize = perPageSize;
    this.onChangePerPage.emit(perPageSize);
  }
}
