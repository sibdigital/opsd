import {Component, OnInit, ViewChild} from "@angular/core";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {ValueOption} from "core-components/homescreen-tabs/municipality/municipality-tab.component";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";

@Component({
  templateUrl: './protocol-tab.html'
})
export class ProtocolTabComponent implements OnInit {
  public compareByHref = AngularTrackingHelpers.compareByHref;
  public options:any[];
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  protected readonly appBasePath:string;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              readonly I18n:I18nService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<ProjectResource>>(this.pathHelper.api.v3.projects.toString())
      .toPromise()
      .then((projects:CollectionResource<ProjectResource>) => {
        this.valueOptions = projects.elements.map((el:ProjectResource) => {
          return {name: el.name, $href: el.id};
        });
        this.value = this.valueOptions[0];
      });
  }

  public get selectedOption() {
    const $href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === $href)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.$href === val.$href);
    this.value = option;
  }

  public handleUserSubmit() {
    if (this.selectedOption) {
    }
  }
}
