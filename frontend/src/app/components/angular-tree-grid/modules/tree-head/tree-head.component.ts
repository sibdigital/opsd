import {Component, OnInit, Input, EventEmitter, ViewEncapsulation} from '@angular/core';
import { Configs } from '../../models/Configs.model';
import { Column } from '../../models/Column.model';
import { Store } from '../../store/store';
import { AngularTreeGridService } from '../../angular-tree-grid.service';

@Component({
  selector: '[db-tree-head]',
  templateUrl: './tree-head.component.html',
  styleUrls: ['./tree-head.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class TreeHeadComponent implements OnInit {

  @Input()
  store:Store;

  @Input()
  configs:Configs;

  @Input()
  expand_tracker:any;

  @Input()
  edit_tracker:any;

  @Input()
  internal_configs:any;

  @Input()
  columns:Column[];

  @Input()
  rowselectall:EventEmitter<any>;

  @Input()
  rowdeselectall:EventEmitter<any>;

  child_columns:Column[];

  constructor(private angularTreeGridService:AngularTreeGridService) { }

  ngOnInit() {
    if (this.configs.subheaders) {
      this.child_columns = this.columns.filter(column => column.parent_name);
      console.log(this.child_columns.length);
      this.columns = this.columns.filter(column => !column.parent_name);
      console.log(this.columns.length);
    }
  }

  addRow() {
    this.internal_configs.show_add_row = true;
  }

  selectAll(e:any) {
    if (e.target.checked) {
      this.angularTreeGridService.selectAll(this.store.getDisplayData());
      this.rowselectall.emit(this.store.getDisplayData());
    } else {
      this.angularTreeGridService.deSelectAll(this.store.getDisplayData());
      this.rowdeselectall.emit(e);
    }
  }

}
