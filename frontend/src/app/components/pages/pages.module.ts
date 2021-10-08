import {PagesComponent} from "core-components/pages/pages.component";
import {PageFormComponent} from "core-components/pages/form/page-form.component";
import {MatPaginatorModule} from "@angular/material/paginator";
import {MatTableModule} from "@angular/material/table";
import {BrowserModule} from "@angular/platform-browser";
import {MatTooltipModule} from "@angular/material/tooltip";
import {NgModule} from "@angular/core";
import {PageViewComponent} from "core-components/pages/view/page-view.component";
import {OpenprojectEditorModule} from "core-app/modules/editor/openproject-editor.module";
@NgModule({
  imports: [
    MatPaginatorModule,
    MatTableModule,
    BrowserModule,
    MatTooltipModule,
    OpenprojectEditorModule
  ],
  providers: [],
  declarations: [
    PagesComponent,
    PageFormComponent,
    PageViewComponent
  ],
  entryComponents: [
    PagesComponent,
    PageFormComponent,
    PageViewComponent
  ],
  exports: [
    PagesComponent,
    PageFormComponent,
    PageViewComponent
  ]
})
export class PagesModule {}

