import {
  Component, EventEmitter,
  Input,
  OnDestroy,
  OnInit, Output,
  ViewEncapsulation
} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";

@Component({
  templateUrl: './projects.table-header.component.html',
  styleUrls: ['./projects.table-header.component.sass'],
  encapsulation: ViewEncapsulation.None,
  selector: 'projects-table-header',
})
export class ProjectsTableHeaderComponent implements OnInit, OnDestroy {

  @Input() headerColumn: any;

  @Input() locale: string;

  @Output() onSort = new EventEmitter<any>();

  directionClass: string;

  sortable: boolean;

  isHierarchyColumn: boolean;

  columnName: string;

  columnType: 'hierarchy' | 'relation' | 'expandAll';

  hierarchyIcon: string;

  isHierarchyDisabled: boolean;

  text: { toggleHierarchy:string, openMenu:string, sortTitle: string } = {
    toggleHierarchy: '',
    openMenu: '',
    sortTitle: '',
  };

  private currentSortDirection: any;

  constructor(
    readonly I18n: I18nService
  ) {
  }

  ngOnInit(): void {
    this.directionClass = this.getDirectionClass();
    this.text = {
      toggleHierarchy: I18n.t('js.work_packages.hierarchy.show'),
      openMenu: I18n.t('js.label_open_menu'),
      sortTitle: `Сортировать по возрастанию "${ this.headerColumn.name }"`,
    };

    this.isHierarchyColumn = this.headerColumn.id === 'name';

    if (this.isHierarchyColumn) {
      this.columnType = 'hierarchy';
    } else {
      this.columnType = 'relation';
    }

    if (this.headerColumn.id === 'expandAll') {
      this.columnType = 'expandAll';
    }

    this.columnName = this.headerColumn.name;

    if (this.isHierarchyColumn) {
      this.setHierarchyIcon();
    }
  }

  ngOnDestroy(): void {
  }

  setHierarchyIcon() {
    this.text.toggleHierarchy = I18n.t('js.work_packages.hierarchy.hide');
    this.hierarchyIcon = 'icon-hierarchy';
  }

  toggleHierarchy(evt: any) {
    evt.stopPropagation();
    return false;
  }

  public get displayDropdownIcon() {
    return true;
  }

  private getDirectionClass(): string {
    switch (this.currentSortDirection) {
      case 'asc':
        this.currentSortDirection = 'desc';
        this.text.sortTitle = `Сортировать по убыванию "${ this.headerColumn.name }"`;
        return 'asc';
      case 'desc':
        this.currentSortDirection = 'asc';
        this.text.sortTitle = `Сортировать по возрастанию "${ this.headerColumn.name }"`;
        return 'desc';
      default:
        this.currentSortDirection = 'asc';
        this.text.sortTitle = `Сортировать по убыванию "${ this.headerColumn.name }"`;
        return 'asc';
    }
  }

  public sortById(): void {
    const sortDir = this.getDirectionClass();
    console.dir({ sortByID: this.headerColumn, sortDir });
    this.onSort.emit({ id: this.headerColumn.id, sortDir });
  }
}
