import {
  Component,
  Input,
  OnDestroy,
  OnInit,
  ViewEncapsulation
} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DatePipe} from "@angular/common";

@Component({
  templateUrl: './projects-table-data-cell.component.html',
  styleUrls: ['./projects.table-data-cell.component.sass'],
  encapsulation: ViewEncapsulation.None,
  selector: 'projects-table-data-cell',
})
export class ProjectsTableDataCellComponent implements OnInit, OnDestroy {

  @Input() project: any;

  @Input() locale: string;

  public dataCell: { name: string } = { name: '' };

  constructor(
    readonly I18n: I18nService,
    public datePipe: DatePipe,
  ) {
  }

  ngOnInit(): void {
    if (this.project) {
      const name = this.project.name ? this.project.name : this.project;
      if (typeof name === 'boolean' && name) {
        this.dataCell.name = 'Общий';
      }
      else if (name instanceof Date && name) {
        this.dataCell.name = this.datePipe.transform(name, 'dd.MM.yyyy') || '';
      }
      else {
        this.dataCell.name = name;
      }
    }
  }

  ngOnDestroy(): void {
  }
}
