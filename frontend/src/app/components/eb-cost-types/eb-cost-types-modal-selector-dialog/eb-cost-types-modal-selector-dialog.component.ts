import {Component, Inject, Input, OnInit, ViewChild} from '@angular/core';
import {MatPaginator} from "@angular/material/paginator";
import {MatSort, MatSortable} from "@angular/material/sort";
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";
import {MatRow, MatTableDataSource} from "@angular/material/table";
import {EbCostTypeService} from "core-components/eb-cost-types/shared/eb-cost-type.service";
import {MatSnackBar} from "@angular/material/snack-bar";
import {EbCostType} from "core-components/eb-cost-types/eb-cost-types.model";
import {CostType} from "core-components/cost-types/cost-type.model";


@Component({
  selector: 'op-eb-cost-types-modal-selector-dialog',
  templateUrl: './eb-cost-types-modal-selector-dialog.component.html',
  styleUrls: ['./eb-cost-types-modal-selector-dialog.component.sass']
})
export class EbCostTypesModalSelectorDialogComponent implements OnInit {

  displayedColumns:string[] = ['id', 'code', 'name', 'costTypeName'];
  dataSource:MatTableDataSource<any>;
  excludedEbCosts:EbCostType[];
  @ViewChild(MatPaginator)  paginator!:MatPaginator;
  @ViewChild(MatSort) sort:MatSort = new MatSort;
  constructor(
    public dialogRef:MatDialogRef<EbCostTypesModalSelectorDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data:any,
    private snackBar:MatSnackBar,
    private ebCostTypeService:EbCostTypeService
  ) {
    this.dataSource = new MatTableDataSource<any>();
    this.excludedEbCosts = this.data.excludedEbCosts;
  }

  ngOnInit():void {
    this.dialogRef.updateSize('80%');
    var exclEbCostIds = this.excludedEbCosts.map(ctr => ctr.id);
    this.ebCostTypeService.getRegEbCostTypesWithAdditionalEbCT().subscribe(
      data => {
        data.forEach(item => {
          if (item.ebCostType && exclEbCostIds.includes(item.ebCostType.id) && !item.costType) {
            var nCostType = new CostType();
            nCostType.name = 'Выбран в данном источнике финансирования';
            item.costType = nCostType;
          }
        });
        this.dataSource.data = data;
        this.sort.sort(({id: 'code', start: "asc"}) as MatSortable);
      }
    );
  }

  ngAfterViewInit() {

    this.dataSource.sortingDataAccessor = (item, property) => {
      switch (property) {
        case 'code': return item.ebCostType.code;
        case 'name': return item.ebCostType.name;
        case 'costTypeName': return item.costType;
        default: return item[property];
      }
    };
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;
  }

  selectEbCostType(row:any) {
    if (row.costType) {
        this.snackBar.open("Данный источник из ЭБ уже выбран в другом типе затрат!", "OK", {
          duration: 3000,
        });
    } else {
      this.dialogRef.close({data: row});
    }
  }

}
