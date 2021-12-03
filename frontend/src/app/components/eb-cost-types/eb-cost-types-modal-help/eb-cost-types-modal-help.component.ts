import {Component, Inject, OnInit} from "@angular/core";
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";
import {MatSnackBar} from "@angular/material/snack-bar";
import {EbCostTypeService} from "core-components/eb-cost-types/shared/eb-cost-type.service";

@Component({
  selector: 'op-eb-cost-types-modal-help',
  templateUrl: './eb-cost-types-modal-help.component.html',
  styleUrls: ['./eb-cost-types-modal-help.component.sass']
})
export class EbCostTypesModalHelpComponent implements OnInit {
  htmlString:string = "";
  constructor(    public dialogRef:MatDialogRef<EbCostTypesModalHelpComponent>,
                  @Inject(MAT_DIALOG_DATA) public data:any,
                  private snackBar:MatSnackBar,
                  private ebCostTypeService:EbCostTypeService) {
  }
  ngOnInit():void {
    this.dialogRef.updateSize('80%', '60%');
  }

}
