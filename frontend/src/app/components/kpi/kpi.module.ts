import {NgModule} from "@angular/core";
import {KPIFormComponent} from "core-components/kpi/form/kpi-form.component";
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatInputModule} from "@angular/material/input";
import {MatDividerModule} from "@angular/material/divider";
import {FormsModule} from "@angular/forms";
import {KPIViewComponent} from "core-components/kpi/view/kpi-view.component";
import {MatTableModule} from "@angular/material/table";
import {MatTooltipModule} from "@angular/material/tooltip";
import {MatPaginatorModule} from "@angular/material/paginator";

@NgModule({
  imports: [
    MatFormFieldModule,
    MatInputModule,
    MatDividerModule,
    FormsModule,
    MatTableModule,
    MatTooltipModule,
    MatPaginatorModule
  ],
  providers: [],
  declarations: [
    KPIFormComponent,
    KPIViewComponent
  ],
  entryComponents: [
    KPIFormComponent,
    KPIViewComponent
  ],
  exports: [
    KPIFormComponent,
    KPIViewComponent
  ]
})
export class KpiModule {}
