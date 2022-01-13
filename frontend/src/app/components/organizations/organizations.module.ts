import {NgModule} from "@angular/core";
import {PositionsListComponent} from "core-components/organizations/positions-list/positions-list.component";
import {MatTableModule} from "@angular/material/table";
import {MatPaginatorModule} from "@angular/material/paginator";
import {MatTooltipModule} from "@angular/material/tooltip";
import {PositionFormComponent} from "core-components/organizations/position-form/position-form.component";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatDividerModule} from "@angular/material/divider";
import {FormsModule} from "@angular/forms";
import {CommonModule} from "@angular/common";
import {MatCheckboxModule} from "@angular/material/checkbox";
import {MatPaginatorIntl} from "@angular/material";
import {CustomMatPaginatorIntl} from "core-components/organizations/custom-mat-paginator-int";

@NgModule({
  imports: [
    MatTableModule,
    MatPaginatorModule,
    MatTooltipModule,
    MatFormFieldModule,
    MatInputModule,
    MatDividerModule,
    FormsModule,
    MatTableModule,
    MatTooltipModule,
    MatPaginatorModule,
    CommonModule,
    MatCheckboxModule
  ],
  providers: [{
    provide: MatPaginatorIntl,
    useClass: CustomMatPaginatorIntl
  }],
  declarations: [
    PositionsListComponent,
    PositionFormComponent
  ],
  entryComponents: [
    PositionsListComponent,
    PositionFormComponent
  ],
  exports: [
    PositionsListComponent,
    PositionFormComponent
  ],
})
export class OrganizationsModule {}
