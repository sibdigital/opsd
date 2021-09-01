import {
  Component,
  Input,
  OnDestroy,
  OnInit,
  ViewEncapsulation
} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";

@Component({
  templateUrl: './projects-table-data-cell.component.html',
  styleUrls: ['./projects.table-data-cell.component.sass'],
  encapsulation: ViewEncapsulation.None,
  selector: 'projects-table-data-cell',
})
export class ProjectsTableDataCellComponent implements OnInit, OnDestroy {

  @Input() project: any;

  @Input() locale: string;

  public dataCell: { name: '' } = { name: '' };

  constructor(
    readonly I18n: I18nService
  ) {
  }

  ngOnInit(): void {
    if (this.project) {
      this.dataCell.name = this.project.name ? this.project.name : this.project;
    } else {
      console.log('nulll ');
    }
  }

  ngOnDestroy(): void {
  }
}
