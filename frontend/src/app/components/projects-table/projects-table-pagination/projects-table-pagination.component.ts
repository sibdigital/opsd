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

  @Input() PerPage: number = 25;
  @Input() CurrentPage: number = 1;
  @Input() Total: number = 1;
  @Input() paginationService: ProjectsTablePaginationService;

  public pagesCount: number = 1;
  public pages: number[] = [];
  public currentPage: number = 1;
  public total: number = 1;
  public last: number = 1;
  public perPage: number = 25;
  public perPages: number[] = [25, 100];
  // public offsetStart: number = 0;
  // public offsetEnd: number = 0;
  public testSizes: number[] = this.pagService.perPagesSizes;

  @Output() onChangePage = new EventEmitter<any>();
  @Output() onChangePerPage = new EventEmitter<any>();

  constructor(
    public pagService: ProjectsTablePaginationService
  ) {
  }

  ngOnInit(): void {
    // console.dir({ PerPage: this.PerPage, CurrentPage: this.CurrentPage, Total: this.Total });
    console.dir({ pagService: this.pagService.page, pagination: this.paginationService.page });
    this.currentPage = this.CurrentPage ? this.currentPage : 0;
    this.total = this.Total ? this.Total : 0;
    this.perPage = this.PerPage ? this.PerPage : 0;
    this.pagesCount = Math.floor(this.total / this.perPage) + 1;
    this.last = this.pagesCount;
    for (let i = 0; i < this.pagesCount; i++) {
      this.pages.push(i + 1);
    }
    // this.offsetStart = ((this.currentPage - 1) * this.perPage) + 1;
    // this.offsetEnd = this.offsetStart + this.perPage - 1;
    // console.dir({ cur: this.currentPage, tot: this.total, pages: this.pages, count: this.pagesCount });
  }

  ngOnDestroy(): void {
  }

  setCurrent(e: any, pageNumber: number) {
    e.preventDefault();
    this.currentPage = pageNumber;
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
    // console.dir({ services: [this.pagService, this.paginationService], perPages: this.paginationService.perPagesSizes });
    return this.pagService.perPagesSizes;
  }

  public setPerPageSize(perPageSize: number) {
    this.pagService.perPageSize = perPageSize;
    this.paginationService.perPageSize = perPageSize;
    this.onChangePerPage.emit(perPageSize);
  }
}
