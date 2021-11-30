import {NgModule} from "@angular/core";
import {MapComponent} from "core-components/map/map.component";
import {MatCardModule} from "@angular/material/card";
import {MatButtonModule} from "@angular/material/button";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatSelectModule} from "@angular/material/select";
import {MatInputModule} from "@angular/material/input";
import {SelectWorkPackageDialog} from "core-components/map/select-work-package-dialog/select-work-package-dialog";
import {CommonModule} from "@angular/common";
import {FormsModule} from "@angular/forms";
import {MatTableModule} from "@angular/material/table";
import {MatPaginatorModule} from "@angular/material/paginator";
import {MatTooltipModule} from "@angular/material/tooltip";
import {MatDialogModule} from "@angular/material/dialog";

@NgModule({
  imports: [
    MatCardModule,
    MatButtonModule,
    MatFormFieldModule,
    MatSelectModule,
    MatInputModule,
    CommonModule,
    FormsModule,
    MatTableModule,
    MatPaginatorModule,
    MatTooltipModule,
    MatDialogModule
  ],
  providers: [],
  declarations: [
    MapComponent,
    SelectWorkPackageDialog
  ],
  entryComponents: [
    MapComponent,
    SelectWorkPackageDialog
  ],
  exports: [
    MapComponent,
    SelectWorkPackageDialog
  ]
})
export class MapModule {}
