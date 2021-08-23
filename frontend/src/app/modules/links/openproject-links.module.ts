import {NgModule} from "@angular/core";
import {OpenprojectCommonModule} from "core-app/modules/common/openproject-common.module";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {LinkListComponent} from "core-app/modules/links/link-list/link-list.component";
import {LinksComponent} from "core-app/modules/links/links.component";
import {LinkListItemComponent} from "core-app/modules/links/link-list/link-list-item.component";

@NgModule({
  imports: [OpenprojectCommonModule],
  providers: [HalResourceService],
  declarations: [
    LinksComponent,
    LinkListComponent,
    LinkListItemComponent
  ],
  entryComponents: [
    LinksComponent,
    LinkListComponent
  ],
  exports: [
    LinkListComponent,
    LinksComponent
  ]
})
export class OpenprojectLinksModule {
}
