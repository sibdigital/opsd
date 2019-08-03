import {Component, ViewChild} from "@angular/core";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";

interface ValueOption {
  name:string;
  dueDate:string;
  $href:string | null;
}

@Component({
  templateUrl: './kpi-tab.html'
})
export class KpiTabComponent {
  public dueDate:string = '';
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  public compareByHref = AngularTrackingHelpers.compareByHref;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) {
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects.toString())
      .toPromise()
      .then((projects:CollectionResource<HalResource>) => {
        this.valueOptions = projects.elements.map((el:HalResource) => {
          return {
            name: el.name,
            dueDate: el.dueDate.due_date,
            $href: el.id
          };
        });
        this.valueOptions.unshift({name: 'Все проекты', dueDate: '', $href: ''});
        this.value = this.valueOptions[0];
        this.handleUserSubmit();
      });
  }

  public get selectedOption() {
    const href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === href)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.$href === val.$href);

    // Special case 'null' value, which angular
    // only understands in ng-options as an empty string.
    if (option && option.$href === '') {
      option.$href = null;
    }

    this.value = option;
  }

  public handleUserSubmit() {
    if (this.selectedOption && this.selectedOption.$href) {
      this.blueChild.changeFilter('project' + this.selectedOption.$href);
      this.dueDate = this.format(this.selectedOption.dueDate);
    } else {
      this.blueChild.changeFilter('project0');
    }
  }

  public format(input:string):string {
    return input.slice(8, 10) + '.' + input.slice(5, 7) + '.' + input.slice(0, 4);
  }
}
