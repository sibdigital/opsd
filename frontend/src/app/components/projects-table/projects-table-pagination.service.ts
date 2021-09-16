import {Injectable, OnDestroy} from "@angular/core";
import { IProjectsPaginationState, DefaultProjectsPaginationState } from "../projects/state/projects.state";


@Injectable()
export class ProjectsTablePaginationService implements OnDestroy {

  private _page: IProjectsPaginationState = DefaultProjectsPaginationState;
  private _perPagesSizes: number[] = [25, 100];
  private _perPageSize: number = 25;
  private _params: {} = { size: 25 };

  constructor(
  ) {
  }

  private setParams(newParams: {}) {
    this._params = { ...this._params, ...newParams };
  }

  public setSortParams(sortParams: {}) {
    this.setParams(sortParams);
  }

  public setCurrentPageParams(currentPageParams: {}) {
    this.setParams(currentPageParams);
  }

  public setPerPageSizeParams(perPageSizeParams: {}) {
    this.setParams(perPageSizeParams);
  }

  get page(): IProjectsPaginationState {
    return this._page;
  }

  set page(value: IProjectsPaginationState) {
    this._page = value;
  }

  get perPageSize(): number {
    return this._perPageSize;
  }

  set perPageSize(value: number) {
    this._page.size = value;
    this._perPageSize = value;
    // this.setParams({ size: value, page: 0 });
  }

  get totalElements(): number {
    return this._page.totalElements;
  }

  set totalElements(value: number) {
    this._page.totalElements = value;
  }

  get totalPages(): number {
    return this._page.totalPages;
  }

  set totalPages(value: number) {
    this._page.totalPages = value;
  }

  get currentPage(): number {
    return this._page.number;
  }

  set currentPage(value: number) {
    this._page.number = value;
  }

  get perPagesSizes(): number[] {
    return this._perPagesSizes;
  }

  set perPagesSizes(value: number[]) {
    this._perPagesSizes = value;
  }

  get params(): {} {
    return this._params;
  }

  set params(value: {}) {
    this._params = value;
  }

  ngOnDestroy(): void {
  }
}
