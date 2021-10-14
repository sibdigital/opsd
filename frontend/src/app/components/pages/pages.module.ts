import {PagesComponent} from "core-components/pages/pages.component";
import {PageFormComponent} from "core-components/pages/form/page-form.component";
import {MatPaginatorModule} from "@angular/material/paginator";
import {MatTableModule} from "@angular/material/table";
import {BrowserModule} from "@angular/platform-browser";
import {MatTooltipModule} from "@angular/material/tooltip";
import {NgModule} from "@angular/core";
import {PageViewComponent} from "core-components/pages/view/page-view.component";
import {OpenprojectEditorModule} from "core-app/modules/editor/openproject-editor.module";
import {FooterComponent} from "core-components/pages/view/footer/footer.component";
import {HeaderComponent} from "core-components/pages/view/header/header.component";
import {NavigationComponent} from "core-components/pages/view/navigation/navigation.component";
import {MarkdownModule} from "ngx-markdown";
import {MatTreeModule} from "@angular/material/tree";
import {MatButtonModule} from "@angular/material/button";
import {MatIconModule} from "@angular/material/icon";
@NgModule({
  imports: [
    MatPaginatorModule,
    MatTableModule,
    BrowserModule,
    MatTooltipModule,
    OpenprojectEditorModule,
    MarkdownModule,
    MatTreeModule,
    MatButtonModule,
    MatIconModule
  ],
  providers: [],
  declarations: [
    PagesComponent,
    PageFormComponent,
    PageViewComponent,
    FooterComponent,
    HeaderComponent,
    NavigationComponent
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

